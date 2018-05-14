#ifndef MESH_PARSER_TRANSFER_H
#define MESH_PARSER_TRANSFER_H

#include <string>

void transfer(const std::string& folder,
              const std::string& filename,
              const std::string& ext_before,
              const std::string& ext_after,
              const std::string& remove);

#endif // MESH_PARSER_TRANSFER_H
