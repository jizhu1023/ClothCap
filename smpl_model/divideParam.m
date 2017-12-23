function [betas, pose, trans, scale] = divideParam(param)

betas = param(1:10);
pose = param(11:11+71);
trans = param(83:85);
scale = param(86);

end