function [normals] = calNormal(faces, vertices)

e1 = vertices(faces(:, 2), :) - vertices(faces(:, 1), :); 
e2 = vertices(faces(:, 3), :) - vertices(faces(:, 2), :);

normal = cross(e1.', e2.').';

for i = 1:size(normal, 1)
    normal(i, :) = normal(i, :) / norm(normal(i, :));
end

normal_pts = zeros(size(vertices));
normal_count = zeros(size(vertices, 1), 1);

for i = 1:size(normal, 1)
    for j = 1:3
        id = faces(i, j);
        normal_pts(id, :) = normal_pts(id, :) + normal(i, :);
        normal_count(id) = normal_count(id) + 1; 
    end
end
normal_pts = normal_pts ./ repmat(normal_count, 1, 3);
normals = normal_pts;

end
