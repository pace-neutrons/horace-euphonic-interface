function euphonic_on()

% Set number of openblas threads to 1 so it doesn't interfere with openmp
setenv('OPENBLAS_NUM_THREADS', '1');

% Check if Euphonic is installed and the correct version
verify_python_modules('euphonic', '0.3.2')

% Check if Euphonic can be loaded
try
    py.importlib.import_module('euphonic');
catch ME
    [ver, ex, isloaded] = pyversion;
    warning(['Couldn''t import Euphonic Python library. Has it been ' ...
             'installed correctly for the currently loaded Python at %s?\n%s'], ...
             ex, ME.message);
end

exists = exist('euphonic_sf');
if exists ~= 2
    warning(['The euphonic_sf function doesn''t exist on the current ' ...
             'MATLAB path or isn''t the expected type (exists returned %d). '...
             'Has euphonic_sf been added to the path?'], exists);
end

% Add current folder to Python search path
hor_eu_interface_path = fileparts(mfilename('fullpath'));
if count(py.sys.path, hor_eu_interface_path) == 0
    insert(py.sys.path,int32(0), hor_eu_interface_path);
end

fprintf('Horace-Euphonic Interface Version %s\n', ...
        get_hor_eu_interface_version());

end
