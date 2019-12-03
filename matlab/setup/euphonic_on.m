function euphonic_on(varargin)
% Do required setup to enable calling euphonic_sf as a Horace disp2sqw
% simulation function
if nargin > 0 && varargin{1} ~= ""
    pyexe_path = varargin{1};
else
    pyexe_path = '/bin/python';
end
if nargin > 1
    euphonic_sf_path = varargin{2};
else
    euphonic_sf_path = 'meuphonic';
end

% Must refresh cache to overwrite matlab 2018's default
% python.internal.redirectstdout with the one in the meuphonic/matlab
% folder if you want to use multiprocessing
addpath([euphonic_sf_path, '/matlab'])
rehash toolboxcache;

% Add euphonic_sf.m to path
addpath([euphonic_sf_path, '/matlab/euphonic']);

% Set number of openblas threads to 1 so it doesn't interfere with
% multiprocessing
setenv('OPENBLAS_NUM_THREADS', '1');

% Load Python, and issue a warning if it has already been loaded
try
    pyversion pyexe_path;
catch ME
    warning(['Couldn''t load Python at %s, has euphonic_on already been ' ...
             'called in this session?\n%s'], pyexe_path, ME.message);
end

if ~ispc
    %  For running on Linux only - avoids incompatible compile time option
    %  clashes leading to segfault
    py.sys.setdlopenflags(int32(10));
end

% Add script to Python's path
insert(py.sys.path,int32(0), [euphonic_sf_path, '/python']);

% Import euphonic.py script
try
    py.importlib.import_module('euphonic_sf');
catch ME
    warning(['Couldn''t import euphonic_sf from %s, has the correct path ' ...
             'been provided?\n%s'], euphonic_sf_path, ME.message);
end

end