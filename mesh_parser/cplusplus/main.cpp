#include <fstream>
#include <iostream>
#include <glm/glm.hpp>

#include <OpenMesh/Core/IO/MeshIO.hh>
#include <OpenMesh/Core/Mesh/TriMesh_ArrayKernelT.hh>

using Mesh = OpenMesh::TriMesh_ArrayKernelT<>;

int main(int argc, char** argv)
{
    if (argc != 2)
    {
        std::cerr << "[error] no mesh filename specified, aborting ..." << std::endl;
        exit(EXIT_FAILURE);
    }
    std::string mesh_filename = std::string(argv[1]);

    std::vector<glm::vec3> vertices;
    std::vector<glm::vec3> normals;
    std::vector<glm::ivec3> faces;
    std::vector<glm::vec2> tex_coords;

    Mesh mesh;
    mesh.request_vertex_normals();
    mesh.request_vertex_texcoords2D();

    if (!mesh.has_vertex_normals() || !mesh.has_vertex_texcoords2D())
    {
        std::cerr << "[error] Vertex normal or texcoords2D invalid." << std::endl;
        return false;
    }

    OpenMesh::IO::Options opt;
    opt += OpenMesh::IO::Options::VertexTexCoord;    
    opt += OpenMesh::IO::Options::VertexNormal;

    if (!OpenMesh::IO::read_mesh(mesh, mesh_filename, opt))
    {
        std::cerr << "[error] Read mesh file failed, invalid mesh file ..." << std::endl;
        exit(EXIT_FAILURE);
    }

    if (!opt.check(OpenMesh::IO::Options::VertexNormal))
    {
        mesh.request_face_normals();
        mesh.update_normals();
        mesh.release_face_normals();
    }

    OpenMesh::MPropHandleT<std::map<int, std::string> > property;
    if (mesh.get_property_handle(property, "TextureMapping"))
    {
        auto texture_property = mesh.property(property);
        std::string texture_name = texture_property[1];
        std::ofstream out("mesh_tex_map.mesh");
        out << texture_name << std::endl;
        out.close();
    }

    // parse obj file
    for (auto v_it = mesh.vertices_begin(); v_it != mesh.vertices_end(); ++v_it)
    {
        vertices.emplace_back(
            mesh.point(*v_it).data()[0],
            mesh.point(*v_it).data()[1],
            mesh.point(*v_it).data()[2]);
    }

    for (auto v_it = mesh.vertices_begin(); v_it != mesh.vertices_end(); ++v_it)
    {
        normals.emplace_back(
            mesh.normal(*v_it).data()[0],
            mesh.normal(*v_it).data()[1],
            mesh.normal(*v_it).data()[2]);
    }

    for (auto f_it = mesh.faces_begin(); f_it != mesh.faces_end(); ++f_it)
    {
        std::vector<int> vertices_index;
        for (auto fv_it = mesh.fv_iter(*f_it); fv_it.is_valid(); ++fv_it)
            vertices_index.emplace_back(fv_it->idx());
        assert(vertices_index.size() == 3);
        faces.emplace_back(vertices_index[0], vertices_index[1], vertices_index[2]);
    }

    // Mesh has texture coordinates attribute
    if (mesh.has_vertex_texcoords2D())
    {
        for (auto v_it = mesh.vertices_begin(); v_it != mesh.vertices_end(); ++v_it)
        {
            tex_coords.emplace_back(
                mesh.texcoord2D(*v_it).data()[0],
                mesh.texcoord2D(*v_it).data()[1]);
        }
    }

    // output data to file
    std::ofstream out;

    out.open("mesh_vertices.mesh", std::ios::binary);
    for (auto& v : vertices)
        out << v.x << " " << v.y << " " << v.z << std::endl;
    out.close();

    out.open("mesh_normals.mesh", std::ios::binary);
    for (auto& n : normals)
        out << n.x << " " << n.y << " " << n.z << std::endl;
    out.close();

    out.open("mesh_faces.mesh", std::ios::binary);
    for (auto& f : faces)
        out << f.x << " " << f.y << " " << f.z << std::endl;
    out.close();

    if (mesh.has_vertex_texcoords2D() && mesh.get_property_handle(property, "TextureMapping"))
    {
        out.open("mesh_tex_coords.mesh", std::ios::binary);
        for (auto& t : tex_coords)
            out << t.x << " " << t.y << std::endl;
        out.close();
    }

    return 0;
}