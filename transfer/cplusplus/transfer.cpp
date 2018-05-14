#include "transfer.h"

#include <iostream>
#include <boost/filesystem.hpp>

#include <OpenMesh/Core/IO/MeshIO.hh>
#include <OpenMesh/Core/Mesh/AttribKernelT.hh>
#include <OpenMesh/Core/Mesh/TriMesh_ArrayKernelT.hh>

using DefaultMesh = OpenMesh::TriMesh_ArrayKernelT<>;

void transfer(const std::string& folder, const std::string& filename,
              const std::string& ext_before, const std::string& ext_after,
              const std::string& remove)
{
    boost::filesystem::path path_in(folder);
    boost::filesystem::path path_out(folder);

    std::string file_in = path_in.append(filename + ext_before).string();
    std::string file_out = path_out.append(filename + ext_after).string();

    std::cout << "[info] transferring " << filename + ext_before << std::endl;

    DefaultMesh mesh;

    OpenMesh::IO::Options opt;
    opt += OpenMesh::IO::Options::VertexColor;
    opt += OpenMesh::IO::Options::ColorAlpha;

    if (!OpenMesh::IO::read_mesh(mesh, file_in, opt))
    {
        std::cerr << "[error] read mesh failed, invalid mesh file ..." << std::endl;
        exit(EXIT_FAILURE);
    }

    mesh.request_vertex_colors();

    if (remove == "true")
        boost::filesystem::remove(file_in);

    for (auto v_it = mesh.vertices_begin(); v_it != mesh.vertices_end(); ++v_it)
    {
        mesh.point(*v_it).data()[0] *= 1000;
        mesh.point(*v_it).data()[1] *= 1000;
        mesh.point(*v_it).data()[2] *= 1000;

        // pants
//        mesh.set_color(*v_it, OpenMesh::Vec3uc(29, 139, 58));
        // shirt
        mesh.set_color(*v_it, OpenMesh::Vec3uc(25, 114, 175));
    }

    OpenMesh::IO::write_mesh(mesh, file_out, opt);
}
