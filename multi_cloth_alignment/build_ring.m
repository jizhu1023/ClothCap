function [ring, boundary] = build_ring(boundary, adjacency_map, label)

ring = zeros(size(boundary));

count = 2;
start = boundary(1);
stop = -1;

while 1
    neighbors = find(adjacency_map(start, :) == 1);
    for i = 1 : length(neighbors)
        p = find(boundary == neighbors(i), 1);
        if isempty(p) || label(neighbors(i)) ~= label(start)
            neighbors(i) = -1;
        end
    end
    neighbors(neighbors == -1 | neighbors == stop) = [];
    
    ring(count) = start;
    count = count + 1;
        
    stop = start;
    start = neighbors(1);
    
    if start == boundary(1)
        ring(1) = stop;
        ring(count) = start;
        break;
    end
end

ring(ring == 0) = [];

for i = 1 : length(ring)   
    boundary(boundary == ring(i)) = [];
end

end

