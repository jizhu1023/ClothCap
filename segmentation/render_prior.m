function [colors] = render_prior(labels)

colors = zeros(length(labels), 3);
for i = 1 : length(labels)
    if labels(i) == 0
        colors(i, :) = [255, 0, 0];
    elseif labels(i) == 1
        colors(i, :) = [0, 255, 0];
    else
        colors(i, :) = [128, 128, 128];    
    end
end

end

