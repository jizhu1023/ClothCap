function [mesh] = mesh_parser(mesh_name, mesh_folder)

cd('mesh_parser');

mesh_filename = ['..', filesep, mesh_folder, filesep, mesh_name];
system(['mesh_parser.exe ', mesh_filename]);

vertices = importdata('mesh_vertices.mesh');
normals = importdata('mesh_normals.mesh');
faces = importdata('mesh_faces.mesh') + 1;
tex_coords = importdata('mesh_tex_coords.mesh');
tex_name = importdata('mesh_tex_map.mesh');

mesh.vertices = vertices;
mesh.normals = normals;
mesh.faces = faces;
mesh.tex_coords = tex_coords;
mesh.uv_map = imread(['..', filesep, mesh_folder, filesep, tex_name{1}]);

delete('*.mesh');

cd('..')

end