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
    
    % Adds the euphonic_sqw_models submodule to the python path
    curdir = split(fileparts(mfilename('fullpath')), filesep);
    moddir = join([curdir(1:end-2); {'euphonic_sqw_models'}], filesep);
    insert(py.sys.path, int32(0), moddir{1});
    
    % Check if Euphonic is installed and the correct version
    req_mods = required_modules;
    try
        verify_python_modules(req_mods{:});
    catch ME
        if ~isempty(strfind(ME.message, 'DistributionNotFound')) ...
            || ~isempty(strfind(ME.message, 'ModuleNotFoundError')) ...
            modules = join(mod_str(req_mods));
            modules = sprintf('%s', modules{:});
            error(sprintf(['The Python modules required are not installed. ' ... 
                  'Please install them with:\npip install ' modules '\n' ...
                  'Or use the ''euphonic.install_python_modules'' script.']));
        else
            rethrow(ME);
        end
    end
    
    % Check if Euphonic can be loaded
    try
        py.importlib.import_module('euphonic');
    catch ME
        [ver, ex, isloaded] = pyversion;
        warning(['Couldn''t import Euphonic Python library.\n' ...
                 'Has it been installed correctly for the currently loaded Python at %s?\n' ...
                 'If not you can install it using ''pip install %s'' on the command line ' ...
                 'or use the Matlab command ''euphonic.install_python_modules'' included ' ...
                 'in this package.\n' ...
                 '\nOriginal error message: %s'], ex, 'euphonic', ME.message);
    end
    
    horace_euphonic_interface_is_initialised = true;
end

end

