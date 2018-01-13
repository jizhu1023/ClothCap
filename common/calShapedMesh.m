function [v_shaped, j_shaped] = calShapedMesh(model, betas)
 
shape_coeffs = model.shapedirs.x; % n * 3 * 10

betas_num = size(shape_coeffs, 3);
if length(betas) ~= betas_num
    fprintf('betas size error!\n');
    return ;
end

betas = reshape(betas, betas_num, []);
shape_coeffs = reshape(shape_coeffs, [], betas_num);

v_offset = shape_coeffs * betas;
v_offset = reshape(v_offset, [], 3);
v_shaped = model.v_template + v_offset; % return shaped mesh vertices

j_shaped = model.J_regressor * v_shaped;

end

