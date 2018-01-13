#define CGAL_BGL_TESTSUITE

#include <OpenMesh/Core/IO/MeshIO.hh>
#include <OpenMesh/Core/Mesh/PolyMesh_ArrayKernelT.hh>

#include <CGAL/Exact_predicates_inexact_constructions_kernel.h>
#include <CGAL/boost/graph/graph_traits_PolyMesh_ArrayKernelT.h>
#include <CGAL/mesh_segmentation.h>
#include <CGAL/property_map.h>

#include <iostream>
#include <fstream>

typedef CGAL::Exact_predicates_inexact_constructions_kernel Kernel;
typedef OpenMesh::PolyMesh_ArrayKernelT<> Mesh;

typedef boost::graph_traits<Mesh>::face_descriptor face_descriptor;
typedef boost::graph_traits<Mesh>::face_iterator face_iterator;

int main(int argc, char** argv)
{
    Mesh mesh;
    OpenMesh::IO::read_mesh(mesh, "ly-apose_texture_00000001_gop.obj");
    if (!CGAL::is_triangle_mesh(mesh))
    {
        std::cerr << "Input geometry is not triangulated." << std::endl;
        return EXIT_FAILURE;
    }
    std::cout << "#F : " << num_faces(mesh) << std::endl;
    std::cout << "#H : " << num_halfedges(mesh) << std::endl;
    std::cout << "#V : " << num_vertices(mesh) << std::endl;

    // create a property-map for SDF values
    typedef std::map<face_descriptor, double> Facet_double_map;
    Facet_double_map internal_sdf_map;
    boost::associative_property_map<Facet_double_map> sdf_property_map(internal_sdf_map);

    // compute SDF values
    std::pair<double, double> min_max_sdf = CGAL::sdf_values(mesh, sdf_property_map);
  
    // It is possible to compute the raw SDF values and post-process them using
    // the following lines:
    // const std::size_t number_of_rays = 25;  // cast 25 rays per facet
    // const double cone_angle = 2.0 / 3.0 * CGAL_PI; // set cone opening-angle
    // CGAL::sdf_values(mesh, sdf_property_map, cone_angle, number_of_rays, false);
    // std::pair<double, double> min_max_sdf =
    // CGAL::sdf_values_postprocessing(mesh, sdf_property_map);
  
    // print minimum & maximum SDF values
    std::cout << "minimum SDF: " << min_max_sdf.first << std::endl
              << "maximum SDF: " << min_max_sdf.second << std::endl;
    
    // calculate vertices sdf from faces sdf
    std::vector<std::pair<int, double>> sdf_values;
    for (auto v_it = mesh.vertices_begin(); v_it != mesh.vertices_end(); ++v_it)
    {
        int face_num = 0;
        double sdf_sum = 0.0;
        for (auto vf_it = mesh.vf_iter(*v_it); vf_it.is_valid(); ++vf_it)
        {
            sdf_sum += sdf_property_map[*vf_it];
            face_num += 1;
        }
        sdf_sum /= face_num;
        sdf_values.emplace_back(std::make_pair(v_it->idx(), sdf_sum));
    }

    // save SDF values
    std::ofstream out_file("sdf_value.txt");
    for (const auto& sdf_value : sdf_values)
        out_file << sdf_value.first << " " << sdf_value.second << std::endl;
    out_file.close();

    return 0;
}