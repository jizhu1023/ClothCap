#include "mesh_parser.h"

#include <fstream>
#include <iostream>

MeshParser::MeshParser()
{
    initialize();
}

MeshParser::MeshParser(const std::string& mesh_name)
{
    initialize();
    load(mesh_name);
}

void MeshParser::load(const std::string& mesh_name)
{
    if (!OpenMesh::IO::read_mesh(mesh_, mesh_name, opt_))
    {
        std::cerr << "[error] Read mesh file failed, invalid mesh file ..." << std::endl;
        exit(EXIT_FAILURE);
    }

    if (!opt_.check(OpenMesh::IO::Options::VertexNormal))
    {
        mesh_.request_face_normals();
        mesh_.update_normals();
        mesh_.release_face_normals();
    }

    max_vert_face_num = 0;
    max_vert_edge_num = 0;
    // parse obj file
    for (auto v_it = mesh_.vertices_begin(); v_it != mesh_.vertices_end(); ++v_it)
    {
        vertices.emplace_back(
            mesh_.point(*v_it).data()[0],
            mesh_.point(*v_it).data()[1],
            mesh_.point(*v_it).data()[2]);

        std::vector<int> faces;
        for (auto vf_it = mesh_.vf_iter(*v_it); vf_it.is_valid(); ++vf_it)
            faces.emplace_back(vf_it->idx());
        vert_faces.insert(std::make_pair(v_it->idx(), faces));

        std::vector<int> edges;
        for (auto ve_it = mesh_.ve_iter(*v_it); ve_it.is_valid(); ++ve_it)
            edges.emplace_back(ve_it->idx());
        vert_edges.insert(std::make_pair(v_it->idx(), edges));

        auto face_n = faces.size();
        max_vert_face_num = max_vert_face_num < face_n ? face_n : max_vert_face_num;

        auto edge_n = edges.size();
        max_vert_edge_num = max_vert_edge_num < edge_n ? edge_n : max_vert_edge_num;
    }

    for (auto v_it = mesh_.vertices_begin(); v_it != mesh_.vertices_end(); ++v_it)
    {
        normals.emplace_back(
            mesh_.normal(*v_it).data()[0],
            mesh_.normal(*v_it).data()[1],
            mesh_.normal(*v_it).data()[2]);
    }

    for (auto v_it = mesh_.vertices_begin(); v_it != mesh_.vertices_end(); ++v_it)
    {
        tex_coords.emplace_back(
            mesh_.texcoord2D(*v_it).data()[0],
            mesh_.texcoord2D(*v_it).data()[1]);
    }

    for (auto f_it = mesh_.faces_begin(); f_it != mesh_.faces_end(); ++f_it)
    {
        std::vector<int> vertices_index;
        for (auto fv_it = mesh_.fv_iter(*f_it); fv_it.is_valid(); ++fv_it)
            vertices_index.emplace_back(fv_it->idx());
        assert(vertices_index.size() == 3);
        faces.emplace_back(vertices_index[0], vertices_index[1], vertices_index[2]);

        std::vector<int> edges_index;
        for (auto fe_it = mesh_.fe_iter(*f_it); fe_it.is_valid(); ++fe_it)
            edges_index.emplace_back(fe_it->idx());
        face_edges.insert(std::make_pair(f_it->idx(), edges_index));
    }

    for (auto e_it = mesh_.edges_begin(); e_it != mesh_.edges_end(); ++e_it)
    {
        auto he0 = mesh_.halfedge_handle(*e_it, 0);
        auto he1 = mesh_.halfedge_handle(*e_it, 1);

        auto from_v = mesh_.from_vertex_handle(he0);
        auto to_v = mesh_.to_vertex_handle(he0);
        edges.emplace_back(from_v.idx(), to_v.idx());

        auto face0 = mesh_.face_handle(he0);
        auto face1 = mesh_.face_handle(he1);
        std::vector<int> f;
        if (face0.is_valid())
            f.emplace_back(face0.idx());
        if (face1.is_valid())
            f.emplace_back(face1.idx());
        edge_faces.insert(std::make_pair(e_it->idx(), f));
    }

    std::for_each(edges.begin(), edges.end(), [](glm::ivec2& edge)
    {
        if (edge[0] > edge[1])
            std::swap(edge[0], edge[1]);
    });
    auto p = std::unique(edges.begin(), edges.end(), [](const glm::ivec2& v1, const glm::ivec2& v2)
    {
        return v1[0] == v2[0] && v1[1] == v2[1];
    });
    edges.erase(p, edges.end());

    std::for_each(vert_faces.begin(), vert_faces.end(), [&](std::pair<const int, std::vector<int>>& pair)
    {
        pair.second.resize(max_vert_face_num, -1);
    });

    std::for_each(vert_edges.begin(), vert_edges.end(), [&](std::pair<const int, std::vector<int>>& pair)
    {
        pair.second.resize(max_vert_edge_num, -1);
    });
}

void MeshParser::initialize()
{
    mesh_.request_vertex_normals();
    mesh_.request_vertex_texcoords2D();

    if (!mesh_.has_vertex_normals() || !mesh_.has_vertex_texcoords2D())
    {
        std::cerr << "[error] Vertex normal or texcoords2D invalid." << std::endl;
        exit(EXIT_FAILURE);
    }

    opt_ = OpenMesh::IO::Options();
    opt_ += OpenMesh::IO::Options::VertexTexCoord;
    opt_ += OpenMesh::IO::Options::VertexNormal;
}

bool MeshParser::textured()
{
    OpenMesh::MPropHandleT<std::map<int, std::string> > property;
    if (mesh_.get_property_handle(property, "TextureMapping"))
    {
        auto texture_property = mesh_.property(property);
        tex_map_name = texture_property[1];
        return true;
    }
    tex_map_name = "";
    return false;
}
