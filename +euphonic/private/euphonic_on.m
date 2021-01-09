function euphonic_on()

global horace_euphonic_interface_is_initialised;
if isempty(horace_euphonic_interface_is_initialised) || ~horace_euphonic_interface_is_initialised

% Set number of openblas threads to 1 so it doesn't interfere with openmp
setenv('OPENBLAS_NUM_THREADS', '1');

% Sets library opening flag on Linux to load C modules immediately and to
% force Matlab to use the math libraries of this module instead of its own.
if ~ispc
    py.sys.setdlopenflags(int32(10));
end

% Check if Euphonic is installed and the correct version
req_mods = required_modules;
verify_python_modules(req_mods{:});

help_text = ['If not you can install it using ''pip install %s'' on the command line ' ...
             'or use the Matlab command ''euphonic.install_python_modules'' included ' ...
             'in this package.'];

% Check if Euphonic can be loaded
try
    py.importlib.import_module('euphonic');
catch ME
    [ver, ex, isloaded] = pyversion;
    warning(['Couldn''t import Euphonic Python library. Has it been ' ...
             'installed correctly for the currently loaded Python at %s?\n' ...
             help_text '\nOriginal error message: %s'], ex, 'euphonic', ME.message);
end
try
    py.importlib.import_module('horace_euphonic_interface');
catch ME
    [ver, ex, isloaded] = pyversion;
    warning(['Couldn''t import Euphonic Python library. Has it been ' ...
             'installed correctly for the currently loaded Python at %s?\n' ...
             help_text '\nOriginal error message: %s'], ex, ...
             'horace_euphonic_interface', ME.message);
end

horace_euphonic_interface_is_initialised = true;
end

end
