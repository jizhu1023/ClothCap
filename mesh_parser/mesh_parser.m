function [mesh] = mesh_parser(mesh_name, mesh_folder)

cd('mesh_parser');

delete('*.mesh');

mesh_filename = ['..', filesep, mesh_folder, filesep, mesh_name];
if strncmp(computer, 'PC', 2)
    system(['mesh_parser.exe ', mesh_filename]);
else
    system(['./mesh_parser ', mesh_filename]);
end

vertices = importdata('d_vertices.mesh');
normals = importdata('d_normals.mesh');
edges = importdata('d_edges.mesh') + 1;
faces = importdata('d_faces.mesh') + 1;

face_edges = importdata('d_face_edges.mesh') + 1;
edge_faces = importdata('d_edge_faces.mesh') + 1;
vert_faces = importdata('d_vert_faces.mesh') + 1;
vert_edges = importdata('d_vert_edges.mesh') + 1;

if exist('d_tex_coords.mesh', 'file') && exist('d_tex_map.mesh', 'file')
    tex_coords = importdata('d_tex_coords.mesh');
    tex_name = importdata('d_tex_map.mesh');
    mesh.tex_coords = tex_coords;
    mesh.uv_map = imread(['..', filesep, mesh_folder, filesep, tex_name{1}]);
end

mesh.vertices = vertices;
mesh.normals = normals;
mesh.edges = edges;
mesh.faces = faces;

mesh.face_edges = face_edges;
mesh.edge_faces = edge_faces;
mesh.vert_faces = vert_faces;
mesh.vert_edges = vert_edges;

n_edges = size(edges, 1);
n_vertices = size(vertices, 1);
adjacency_map = zeros(n_vertices, n_vertices);
for i = 1 : n_edges
    adjacency_map(edges(i, 1), edges(i, 2)) = 1;
    adjacency_map(edges(i, 2), edges(i, 1)) = 1;
end
mesh.adjacency_map = adjacency_map;

delete('*.mesh');

cd('..')

end