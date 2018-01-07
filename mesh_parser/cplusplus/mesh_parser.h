#ifndef _MESHPARSER_H_
#define _MESHPARSER_H_

#include <glm/glm.hpp>
#include <OpenMesh/Core/IO/MeshIO.hh>
#include <OpenMesh/Core/Mesh/TriMesh_ArrayKernelT.hh>

using DefaultMesh = OpenMesh::TriMesh_ArrayKernelT<>;

class MeshParser
{
public:
    std::vector<glm::vec3> vertices;
    std::vector<glm::vec3> normals;
    std::vector<glm::vec2> tex_coords;

    std::vector<glm::ivec3> faces;
    std::vector<glm::ivec2> edges;
    std::map<int, std::vector<int>> vert_faces;
    std::map<int, std::vector<int>> vert_edges;
    std::map<int, std::vector<int>> edge_faces;
    std::map<int, std::vector<int>> face_edges;

    std::string tex_map_name;

    size_t max_vert_face_num;
    size_t max_vert_edge_num;

    MeshParser();
    explicit MeshParser(const std::string& mesh_name);

    void initialize();
    void load(const std::string& mesh_name);
    bool textured();

private:
    DefaultMesh mesh_;
    OpenMesh::IO::Options opt_;
};

#endif // _MESHPARSER_H_
