function [colors] = render_unary(unary)

[~, ind] = min(unary, [], 2);
colors = zeros(length(ind), 3);

for i = 1 : length(ind)
%     if unary(i, :) == zeros(1, 3)
%         colors(i, :) = [128, 128, 128];
%         continue;
%     end
    
    if ind(i) == 1 % skin
        colors(i, :) = [255, 255, 0];
    elseif ind(i) == 2 % t-shirt
        colors(i, :) = [0, 0, 255];
    else % pants
        colors(i, :) = [255, 0, 0];    
    end
end

end

