function [rings_shirt, rings_pants] = garment_ring(garments, mesh, label)

adj_map = mesh.adjacency_map;

%% for shirt
boundary = garments.shirt.boundary_ind;

[ring1, boundary] = build_ring(boundary, adj_map, label);
[ring2, boundary] = build_ring(boundary, adj_map, label);
[ring3, boundary] = build_ring(boundary, adj_map, label);
[ring4, boundary] = build_ring(boundary, adj_map, label);

total_length = length(ring1) + length(ring2) + length(ring3) + length(ring4);
if total_length ~= length(garments.shirt.boundary_ind) + 8 || ~isempty(boundary)
    disp("[warning] somthing wrong when finding garment boundary rings.");
end

rings_shirt = {ring1, ring2, ring3, ring4};

%% for pants
boundary = garments.pants.boundary_ind;

[ring1, boundary] = build_ring(boundary, adj_map, label);
[ring2, boundary] = build_ring(boundary, adj_map, label);
[ring3, boundary] = build_ring(boundary, adj_map, label);

total_length = length(ring1) + length(ring2) + length(ring3);
if total_length ~= length(garments.pants.boundary_ind) + 6 || ~isempty(boundary)
    disp("[warning] somthing wrong when finding garment boundary rings.");
end

rings_pants = {ring1, ring2, ring3};

end

