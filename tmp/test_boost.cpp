#include <boost/system/error_code.hpp>
#include <boost/filesystem.hpp>
int main() {
    boost::system::error_category const& cat = boost::system::system_category();
    boost::filesystem::path p("/tmp");
    return 0;
}
