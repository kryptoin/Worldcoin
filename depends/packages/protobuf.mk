package=protobuf
$(package)_version=$(native_protobuf_version)
$(package)_download_path=$(native_protobuf_download_path)
$(package)_file_name=$(native_protobuf_file_name)
$(package)_sha256_hash=$(native_protobuf_sha256_hash)
$(package)_dependencies=native_protobuf

def $(package)_set_vars
  $(package)_config_opts=--disable-shared --with-protoc=$(build_prefix)/bin/protoc
  $(package)_config_opts_linux=--with-pic
endef

def $(package)_config_cmds
  $($(package)_autoconf)
endef

def $(package)_build_cmds
  $(MAKE) -C src libprotobuf.la
endef

def $(package)_stage_cmds
  $(MAKE) DESTDIR=$($(package)_staging_dir) -C src install-libLTLIBRARIES install-nobase_includeHEADERS &&\
  $(MAKE) DESTDIR=$($(package)_staging_dir) install-pkgconfigDATA
endef

def $(package)_postprocess_cmds
  rm lib/libprotoc.a
endef

