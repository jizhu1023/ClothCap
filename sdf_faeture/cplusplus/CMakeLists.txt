cmake_minimum_required(VERSION 3.0)
project(sdf_extractor)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/")

# CGAL and its components
find_package(CGAL REQUIRED COMPONENTS)

# include helper file
include(${CGAL_USE_FILE})

find_package(OpenMesh REQUIRED)
include_directories(${OPENMESH_INCLUDE_DIRS})
link_libraries(${OPENMESH_LIBRARIES})

include(CGAL_CreateSingleSourceCGALProgram)
create_single_source_cgal_program("sdf_extractor.cpp")
target_link_libraries(sdf_extractor ${OPENMESH_LIBRARIES})
