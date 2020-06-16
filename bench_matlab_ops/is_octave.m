function out = is_octave
persistent val
if isempty(val)
    v = ver;
    val = ismember('Octave', {v.Name});
end
out = val;
end