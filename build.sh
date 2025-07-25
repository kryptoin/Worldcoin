#!/bin/bash
set -x
cd "$(dirname "$0")"
# Exit on error
set -e

# --- Environment Setup ---
echo "Setting up build environment..."

# Berkeley DB and Boost paths
BDB_PREFIX="/usr/local/bdb4"
BOOST_LIBDIR="/usr/lib64"

# Compiler setup
export CC="gcc"
export CXX="g++"
export CPP="gcc -E"

# System flags for Linux
SYSTEM_FLAGS=""

# --- Compiler and Linker Flags ---
ABI_FLAGS="-D_GLIBCXX_USE_CXX11_ABI=1"
SYSTEM_FLAGS="$SYSTEM_FLAGS -O3 -Wall -fPIC"

# Compiler flags
export CFLAGS="$SYSTEM_FLAGS"
export CXXFLAGS="$SYSTEM_FLAGS -std=c++14 -I${BDB_PREFIX}/include -DNO_SSE $ABI_FLAGS"

# Preprocessor flags
export CPPFLAGS="-I${BDB_PREFIX}/include -I/usr/include"

# Linker flags with RPATH for Berkeley DB
export LDFLAGS="-L${BDB_PREFIX}/lib -L$(pwd)/src/leveldb/out-static -L/usr/lib64 -Wl,-rpath,${BDB_PREFIX}/lib"

# Runtime library path
export LD_LIBRARY_PATH="${BDB_PREFIX}/lib:$LD_LIBRARY_PATH"

export BOOST_ROOT=/usr
export BOOST_INCLUDEDIR=/usr/include
export BOOST_LIBRARYDIR=/usr/lib64

# CRITICAL: Set LIBS with all required boost and system libraries BEFORE configure
export LIBS="-lboost_system -lboost_filesystem -lboost_thread -lboost_program_options -lboost_chrono -lboost_date_time -lpthread -lrt -lssl -lcrypto -lz -lbz2 -ldl"

# Verify Berkeley DB exists
if [ ! -d "$BDB_PREFIX" ]; then
    echo "Error: Berkeley DB not found at $BDB_PREFIX"
    echo "Please ensure Berkeley DB 4.8 is installed"
    exit 1
fi

# Verify Boost exists
if [ ! -d "$BOOST_LIBDIR" ]; then
    echo "Error: Boost libraries not found at $BOOST_LIBDIR"
    echo "Please ensure Boost development packages are installed"
    exit 1
fi

echo "Environment configured."

# --- Build Dependencies ---
echo "Building LevelDB using its custom build system..."

# Build LevelDB using its custom build system
(
  cd src/leveldb

  # Clean any previous builds
  rm -rf out-static out-shared 2>/dev/null || true
  rm -f build_config.mk 2>/dev/null || true

  # Check what build system files exist
  echo "LevelDB build files found:"
  ls -la | grep -E "(Makefile|build_|configure|CMake)" || echo "No standard build files found"

  # Try different build approaches based on what's available
  if [ -f "build_detect_platform" ]; then
    echo "Using build_detect_platform to generate Makefile..."
    # Generate the build configuration
    ./build_detect_platform build_config.mk ./

    # Create the Makefile if it doesn't exist
    if [ ! -f "Makefile" ]; then
      echo "Generating Makefile..."
      cat > Makefile << 'EOF'
include build_config.mk

LIBOBJECTS = $(SOURCES:.cc=.o)

out-static/libleveldb.a: $(LIBOBJECTS)
  mkdir -p out-static
  $(AR) -rs $@ $(LIBOBJECTS)

out-static/libmemenv.a: helpers/memenv/memenv.o
  mkdir -p out-static
  $(AR) -rs $@ helpers/memenv/memenv.o

%.o: %.cc
  $(CXX) $(CXXFLAGS) $(PLATFORM_CXXFLAGS) -c $< -o $@

clean:
  rm -f $(LIBOBJECTS) helpers/memenv/memenv.o
  rm -rf out-static out-shared

.PHONY: clean
EOF
    fi

    # Build with the generated Makefile
    env CC="$CC" \
        CXX="$CXX" \
        CFLAGS="$CFLAGS" \
        CXXFLAGS="$CXXFLAGS -I. -Iinclude" \
        make out-static/libleveldb.a out-static/libmemenv.a

  elif [ -f "CMakeLists.txt" ]; then
    echo "Using CMake build system..."
    mkdir -p build
    cd build
    cmake -DCMAKE_BUILD_TYPE=Release \
          -DLEVELDB_BUILD_TESTS=OFF \
          -DLEVELDB_BUILD_BENCHMARKS=OFF \
          -DCMAKE_C_COMPILER="$CC" \
          -DCMAKE_CXX_COMPILER="$CXX" \
          -DCMAKE_C_FLAGS="$CFLAGS" \
          -DCMAKE_CXX_FLAGS="$CXXFLAGS" \
          ..
    make
    # Copy libraries to expected location
    mkdir -p ../out-static
    cp libleveldb.a ../out-static/
    cd ..

  else
    echo "Trying direct compilation..."
    # Fallback: compile directly
    mkdir -p out-static

    # Compile all .cc files
    for file in db/*.cc table/*.cc util/*.cc; do
      if [ -f "$file" ]; then
        echo "Compiling $file"
        $CXX $CXXFLAGS -Iinclude -I. -c "$file" -o "${file%.cc}.o"
      fi
    done

    # Create static library
    ar rcs out-static/libleveldb.a db/*.o table/*.o util/*.o 2>/dev/null || true

    # Build memenv
    if [ -f "helpers/memenv/memenv.cc" ]; then
      $CXX $CXXFLAGS -Iinclude -I. -c helpers/memenv/memenv.cc -o helpers/memenv/memenv.o
      ar rcs out-static/libmemenv.a helpers/memenv/memenv.o
    fi
  fi

  # Verify libraries were built
  if [ -f "out-static/libleveldb.a" ]; then
    echo "✓ libleveldb.a built successfully"
  else
    echo "✗ Failed to build libleveldb.a"
    exit 1
  fi

  if [ -f "out-static/libmemenv.a" ]; then
    echo "✓ libmemenv.a built successfully"
  else
    echo "✗ Failed to build libmemenv.a"
    exit 1
  fi
)

echo "LevelDB built successfully."

# Clean any previous configure attempts
echo "Cleaning previous configure attempts..."
make clean 2>/dev/null || true
make distclean 2>/dev/null || true

echo "Running autogen.sh..."
sh autogen.sh

echo "Running configure with proper boost linking..."
./configure --without-gui \
            --with-wallet \
            --enable-hardening \
            --without-zmq \
            --enable-cxx \
            --with-unsupported-ssl \
            --disable-tests \
            --without-miniupnpc \
            --with-incompatible-bdb \
            --with-boost-libdir="$BOOST_LIBDIR" \
            --disable-dependency-tracking \
            CPPFLAGS="$CPPFLAGS" \
            CXXFLAGS="$CXXFLAGS" \
            LDFLAGS="$LDFLAGS" \
            LIBS="$LIBS"

# Copy config.h if needed
if [ -f "config.h" ] && [ ! -f "src/bitcoin-config.h" ]; then
    cp config.h src/bitcoin-config.h
fi

echo "Configuring and building secp256k1 submodule..."
(
  cd src/secp256k1
  
  # Create m4 directory and copy required files
  mkdir -p m4
  if [ -f "../../build-aux/m4/secp256k1.m4" ]; then
    cp ../../build-aux/m4/secp256k1.m4 m4/
  fi
  
  # Clean previous builds
  make clean || true
  
  # Run autogen
  sh autogen.sh
  
  # Configure secp256k1
  env CC="$CC" \
      CFLAGS="$CFLAGS" \
      CXX="$CXX" \
      CXXFLAGS="$CXXFLAGS" \
      LDFLAGS="" \
      CPPFLAGS="" \
      ./configure --disable-shared --with-pic --disable-tests --disable-benchmark
  
  # Build secp256k1
  make libsecp256k1.la
)

echo "secp256k1 submodule built."

# Update LDFLAGS to force static inclusion of LevelDB + memenv archives
LEVELDB_STATIC_DIR="$(pwd)/src/leveldb/out-static"
export LDFLAGS="$LDFLAGS $LEVELDB_STATIC_DIR/libleveldb.a $LEVELDB_STATIC_DIR/libmemenv.a -ldb_cxx -largon2"

# Avoid using -lleveldb / -lmemenv to prevent fallback to shared objects
export LIBS="$LIBS -largon2"


echo "Building main project..."

echo "Patching Makefiles to ensure proper static linking and ABI compatibility..."

LEVELDB_STATIC_DIR="$(pwd)/src/leveldb/out-static"

# Ensure -lpthread and -ldl are present in LIBS and LDFLAGS
find . -name "Makefile" -exec sed -i '/^LIBS[[:space:]]*=/{s/$/ -lpthread -ldl/}' {} \;
find . -name "Makefile" -exec sed -i '/^LDFLAGS[[:space:]]*=/{s/$/ -lpthread -ldl/}' {} \;

# Inject -largon2 into LDADD and LIBS (only if not already present)
find ./src -name "Makefile" -exec sed -i '/^LDADD[[:space:]]*=/{/largon2/!s/$/ -largon2/}' {} \;
find ./src -name "Makefile" -exec sed -i '/^LIBS[[:space:]]*=/{/largon2/!s/$/ -largon2/}' {} \;

# Remove dynamic -lleveldb and -lmemenv
find ./src -name "Makefile" -exec sed -i 's/-lleveldb//g' {} \;
find ./src -name "Makefile" -exec sed -i 's/-lmemenv//g' {} \;

# Add static .a paths explicitly
find ./src -name "Makefile" -exec sed -i "/^LDADD[[:space:]]*=/{s|$| $LEVELDB_STATIC_DIR/libleveldb.a $LEVELDB_STATIC_DIR/libmemenv.a|}" {} \;
find ./src -name "Makefile" -exec sed -i "/^LIBS[[:space:]]*=/{s|$| $LEVELDB_STATIC_DIR/libleveldb.a $LEVELDB_STATIC_DIR/libmemenv.a|}" {} \;

# Ensure ABI compatibility
find ./src -name "Makefile" -exec sed -i '/^CXXFLAGS[[:space:]]*=/{/D_GLIBCXX_USE_CXX11_ABI=1/!s/$/ -D_GLIBCXX_USE_CXX11_ABI=1/}' {} \;


make -j$(nproc)
echo "Build finished."
