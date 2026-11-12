function outmat = normalizeMat(inmat)
% normalize image matrix values on a scale of 0 to 1
    outmat = (inmat-min(min(inmat)))/(max(max(inmat))-min(min(inmat)));
end