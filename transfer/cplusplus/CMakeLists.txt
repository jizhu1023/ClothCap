cmake_minimum_required(VERSION 3.0)

project(mesh_parser)

if(NOT WIN32)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=c99")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
    add_definitions(-D_GNU_SOURCE -fPIC)
endif()

find_package(glm REQUIRED)
include_directories(${glm_INCLUDE_DIRS})

find_package(Boost REQUIRED)
include_directories(${Boost_INCLUDE_DIRS})
link_libraries(${Boost_LIBRARIES})

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/")
find_package(OpenMesh REQUIRED)
include_directories(${OPENMESH_INCLUDE_DIRS})
link_libraries(${OPENMESH_LIBRARIES})

add_executable(transfer main.cpp OptionParser.cpp transfer.cpp)
target_link_libraries(transfer boost_system boost_filesystem)