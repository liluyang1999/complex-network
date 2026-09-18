function value = integer(value, name, lower, upper)
%INTEGER Validate a bounded integer before converting integer classes to double.
if ~(isnumeric(value) && isreal(value) && isscalar(value) && ...
        isfinite(value) && value >= lower && value <= upper && fix(value) == value)
    error('cn:InvalidInteger', '%s must be an integer in [%g, %g].', name, lower, upper);
end
value = double(value);
end
