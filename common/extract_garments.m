function [garments, mesh_garments] = extract_garments(mesh, label)

n_edges = size(mesh.edges, 1);
n_faces = size(mesh.faces, 1);
n_vertices = size(mesh.vertices, 1);

n_boundary_skin = 1;
boundary_skin = zeros(n_vertices, 1);

n_boundary_shirt = 1;
boundary_shirt = zeros(n_vertices, 1);

n_boundary_pants = 1;
boundary_pants = zeros(n_vertices, 1);

n_boundary_faces = 1;
boundary_faces = zeros(n_faces, 2);

for i = 1 : n_edges
    edge = mesh.edges(i, :);
    if label(edge(1)) == label(edge(2))
        continue;
    end
    
    boundary_faces(n_boundary_faces, :) = mesh.edge_faces(i, :);
    n_boundary_faces = n_boundary_faces + 1;
    
    if label(edge(1)) == 0
        boundary_skin(n_boundary_skin) = edge(1);
        n_boundary_skin = n_boundary_skin + 1;
    elseif label(edge(1)) == 1
        boundary_shirt(n_boundary_shirt) = edge(1);
        n_boundary_shirt = n_boundary_shirt + 1;
    elseif label(edge(1)) == 2
        boundary_pants(n_boundary_pants) = edge(1);
        n_boundary_pants = n_boundary_pants + 1;
    end
    
    if label(edge(2)) == 0
        boundary_skin(n_boundary_skin) = edge(2);
        n_boundary_skin = n_boundary_skin + 1;
    elseif label(edge(2)) == 1
        boundary_shirt(n_boundary_shirt) = edge(2);
        n_boundary_shirt = n_boundary_shirt + 1;
    elseif label(edge(2)) == 2
        boundary_pants(n_boundary_pants) = edge(2);
        n_boundary_pants = n_boundary_pants + 1;
    end
end

boundary_skin = boundary_skin(1:n_boundary_skin-1, :);
boundary_skin = unique(boundary_skin);

boundary_shirt = boundary_shirt(1:n_boundary_shirt-1, :);
boundary_shirt = unique(boundary_shirt);

boundary_pants = boundary_faces(1:n_boundary_pants-1, :);
boundary_pants = unique(boundary_pants);

boundary_faces = boundary_faces(1:n_boundary_faces-1, :);
boundary_faces(isnan(boundary_faces)) = [];
boundary_faces = unique(boundary_faces);

ind_skin = find(label == 0);
ind_shirt = find(label == 1);
ind_pants = find(label == 2);

% skin garment mesh faces
faces_skin_ind = garment_faces(mesh, ind_skin, boundary_faces);
% shirt garment mesh faces
faces_shirt_ind = garment_faces(mesh, ind_shirt, boundary_faces);
% pants garment mesh faces
faces_pants_ind = garment_faces(mesh, ind_pants, boundary_faces);

% assemble garments vertices index
garments.skin.vertices_ind = ind_skin;
garments.shirt.vertices_ind = ind_shirt;
garments.pants.vertices_ind = ind_pants;

% assemble garments faces index
garments.skin.faces_ind = faces_skin_ind;
garments.shirt.faces_ind = faces_shirt_ind;
garments.pants.faces_ind = faces_pants_ind;

% assemble boundary index
garments.skin.boundary_ind = boundary_skin;
garments.shirt.boundary_ind = boundary_shirt;
garments.pants.boundary_ind = boundary_pants;

mesh_garments = mesh;
mesh_garments.faces(boundary_faces, :) = [];
mesh_garments.colors = render_labels(label);

end

