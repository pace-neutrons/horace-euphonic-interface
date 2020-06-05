function euphonic_on()

% Set number of openblas threads to 1 so it doesn't interfere with openmp
setenv('OPENBLAS_NUM_THREADS', '1');

% Check if Euphonic can be loaded
try
    py.importlib.import_module('euphonic');
catch ME
    [ver, ex, isloaded] = pyversion;
    warning(['Couldn''t import Euphonic Python library. Does the ' ...
             'currently loaded Python at %s have Euphonic installed?\n%s'], ...
             ex, ME.message);
end

exists = exist('euphonic_sf');
if exists ~= 2
    warning(['The euphonic_sf function doesn''t exist on the current ' ...
             'MATLAB path or isn''t the expected type (exists returned %d). '...
             'Has euphonic_sf been added to the path?'], exists);
end

end
