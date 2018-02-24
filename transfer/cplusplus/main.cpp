#include <string>
#include <iostream>
#include <boost/filesystem.hpp>

#include "transfer.h"
#include "OptionParser.h"

using optparse::OptionParser;
using optparse::Values;

namespace fs = boost::filesystem;

int main(int argc, char** argv)
{
    // option parser
    OptionParser option_parser = OptionParser();

    option_parser.add_option("-m", "--mode").dest("mode").set_default("obj2ply")
        .help("transfer option, should be in [obj2ply|ply2obj]");
    option_parser.add_option("-p", "--path").dest("path").set_default("./")
        .help("path to the mesh files, absolute or relative.");
    option_parser.add_option("-r", "--remove").dest("remove").set_default("false")
        .help("whether to remove origin file.");

    Values options = option_parser.parse_args(argc, argv);

    std::string mode = std::string(options["mode"]);
    std::string path = std::string(options["path"]);
    std::string remove = std::string(options["remove"]);

    // check arguments
    fs::path data_path(path);
    if (!fs::exists(data_path))
    {
        std::cerr << "[error] file path" << path << " doesn't exist ..." << std::endl;
        exit(EXIT_FAILURE);
    }

    auto r = std::find(mode.begin(), mode.end(), '2');
    if (r == mode.end())
    {
        std::cerr << "[error] invalid argument" << mode << std::endl;
        exit(EXIT_FAILURE);
    }
    std::string ext_before = mode.substr(0, (unsigned long)(std::distance(mode.begin(), r)));
    std::string ext_after = mode.substr((unsigned long)(std::distance(mode.begin(), r)) + 1, mode.length());
    ext_before.insert(ext_before.begin(), '.');
    ext_after.insert(ext_after.begin(), '.');

    // start transfer

    std::cout << data_path.string() << std::endl;

    fs::directory_iterator iter_begin(data_path);
    fs::directory_iterator iter_end;

    for (; iter_begin != iter_end; ++iter_begin)
    {
        if (fs::is_regular_file(*iter_begin) &&
            iter_begin->path().extension() == ext_before)
        {
            transfer(data_path.string(), iter_begin->path().stem().string(),
                     ext_before, ext_after, remove);
        }
    }

    return 0;
}