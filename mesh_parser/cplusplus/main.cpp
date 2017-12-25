#include "mesh_parser.h"

#include <fstream>
#include <iostream>

int main(int argc, char** argv)
{
    if (argc != 2)
    {
        std::cerr << "[error] no mesh filename specified, aborting ..." << std::endl;
        exit(EXIT_FAILURE);
    }
    std::string mesh_filename = std::string(argv[1]);

    MeshParser mesh_parser(mesh_filename);

    // output data to file
    std::ofstream out;

    out.open("mesh_vertices.mesh", std::ios::binary);
    for (auto& v : mesh_parser.vertices)
        out << v.x << " " << v.y << " " << v.z << std::endl;
    out.close();

    out.open("mesh_normals.mesh", std::ios::binary);
    for (auto& n : mesh_parser.normals)
        out << n.x << " " << n.y << " " << n.z << std::endl;
    out.close();

    out.open("mesh_faces.mesh", std::ios::binary);
    for (auto& f : mesh_parser.faces)
        out << f.x << " " << f.y << " " << f.z << std::endl;
    out.close();

    out.open("mesh_edges.mesh", std::ios::binary);
    for (auto& e : mesh_parser.edges)
        out << e.x << " " << e.y << std::endl;
    out.close();

    if (mesh_parser.textured())
    {
        out.open("mesh_tex_map.mesh", std::ios::binary);
        out << mesh_parser.tex_map_name << std::endl;
        out.close();

        out.open("mesh_tex_coords.mesh", std::ios::binary);
        for (auto& t : mesh_parser.tex_coords)
            out << t.x << " " << t.y << std::endl;
        out.close();
    }

    return 0;
}
