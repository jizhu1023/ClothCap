function [colors] = render_texture(tex_coords, uv_map)

[width, height, ~] = size(uv_map);
[n_point, ~] = size(tex_coords);

colors = zeros(n_point, 3);
for i = 1 : n_point
    u = tex_coords(i, 1) * width;
    v = tex_coords(i, 2) * height;
    colors(i, :) = uv_map(height - floor(v) - 1, floor(u) + 1, :);
end

end

