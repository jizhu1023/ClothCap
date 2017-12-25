function [mesh] = mesh_parser(mesh_name, mesh_folder)

cd('mesh_parser');

mesh_filename = ['..', filesep, mesh_folder, filesep, mesh_name];
if strncmp(computer, 'PC', 2)
    system(['mesh_parser.exe ', mesh_filename]);
else
    system(['./mesh_parser ', mesh_filename]);
end

vertices = importdata('mesh_vertices.mesh');
normals = importdata('mesh_normals.mesh');
edges = importdata('mesh_edges.mesh') + 1;
faces = importdata('mesh_faces.mesh') + 1;

if exist('mesh_tex_coords.mesh', 'file') && exist('mesh_tex_map.mesh', 'file')
    tex_coords = importdata('mesh_tex_coords.mesh');
    tex_name = importdata('mesh_tex_map.mesh');
    mesh.tex_coords = tex_coords;
    mesh.uv_map = imread(['..', filesep, mesh_folder, filesep, tex_name{1}]);
end

mesh.vertices = vertices;
mesh.normals = normals;
mesh.edges = edges;
mesh.faces = faces;

delete('*.mesh');

cd('..')

end