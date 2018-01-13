function [v_posed, j_posed] = calPosedMesh(model, pose, v_shaped, j_shaped, enablePoseBlendShape)

if nargin < 5
    enablePoseBlendShape = 1;
end

joints_num = size(model.J, 1);
if length(pose) ~= joints_num*3
    fprintf('pose size error!\n');
    return ;
end

pose = reshape(pose, 3, []);
if enablePoseBlendShape
    pose_rodrigues = zeros((joints_num-1)*9, 1);
    for i = 2:joints_num
        tmp_R = rodrigues(pose(:, i)) - eye(3);
        pose_rodrigues((i-2)*9+1:(i-1)*9) = reshape(tmp_R', 1, []);
    end
    pose_coeffs = model.posedirs; % n * 3 * 207
    pose_coeffs = reshape(pose_coeffs, [], (joints_num-1)*9);
    v_offset = pose_coeffs * pose_rodrigues;
    v_offset = reshape(v_offset, [], 3);
    v_posed = v_shaped + v_offset;
else
    v_posed = v_shaped;
end

id_to_col = model.kintree_table(2, :); % length 24
parent = id_to_col(model.kintree_table(1, 2:end) + 1) + 1; % length 23

A = zeros(4, 4, joints_num);
A(:, :, 1) = with_zeros(rodrigues(pose(:, 1)), j_shaped(1, :)');

for i = 2:joints_num
    parent_idx = parent(i-1);
    A(:, :, i) = A(:, :, parent_idx) * ...
        with_zeros(rodrigues(pose(:, i)), j_shaped(i, :)' - j_shaped(parent_idx, :)');
end

A_global = A;
for i = 1:joints_num
    A(:, :, i) = A(:, :, i) - pack(A(:, :, i) * [j_shaped(i, :), 0]');
end

j_posed = zeros(joints_num, 3);
for i = 1:joints_num
    j_posed(i, :) = A_global(1:3, 4, i)';
end

A_colwise = reshape(A, [], joints_num);
A_perVert = A_colwise * model.weights';

A_perVert = reshape(A_perVert, 4, 4, []);

for i = 1:size(A_perVert,3)
    new_pos = A_perVert(:, :, i) * [v_posed(i, :), 1]';
    v_posed(i, :) = new_pos(1:3);
end

end

function [Rt] = pack(t)
Rt = [zeros(4, 3), t];
end

function [Rt] = with_zeros(R, t)
Rt = [R, t];
Rt = [Rt; 0, 0, 0, 1];
end



