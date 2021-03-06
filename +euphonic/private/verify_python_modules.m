% brillem -- a MATLAB interface for brille
% Copyright 2020 Greg Tucker
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <https://www.gnu.org/licenses/>.

function verify_python_modules(varargin)
if nargin > 1 && ~isstruct(varargin{1})
    mods = struct(varargin{:});
elseif nargin > 1 && isstruct(varargin{1})
    mods = varargin{1};
else
    error('euphonic_horace_interface:verify_python_modules:input','Wrong input');
end
 
min_py_ver = '3.6';
try
    %pyenv only available from r2019b
    pye = pyenv();
    pyv = pye.Version;
catch ME
    if (strcmp(ME.identifier,'MATLAB:UndefinedFunction'))
        pyv = pyversion;
    else
        rethrow(ME)
    end
end

if ~semver_compatible(pyv, min_py_ver)
  error('euphonic_horace_interface:verify_python_modules:pythonVersion',...
        'euphonic-horace-interface requires Python >= %s', min_py_ver);
end

for mod = fieldnames(mods)'
    try
        ver = char(py.pkg_resources.get_distribution(mod{:}).version);
    catch
        try
            % Try to get version directly
            imp_mod = py.importlib.import_module(mod{:});
            ver = char(py.getattr(imp_mod, '__version__'));
        catch prob
            error('euphonic_horace_interface:verify_python_modules:modVersionUnavailable',...
                'Problem obtaining %s module version string\n%s',...
                 mod{:}, prob.message);
        end
    end

    if ~semver_compatible(ver, mods.(mod{:}))
      error('euphonic_horace_interface:verify_python_modules:modIncompatibleVersion',...
            '%s >= %s required but %s present',mod{:}, mods.(mod{:}), ver);
    end
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ret = semver_compatible(ver_str, req_ver_str)
  ver = semver_split(ver_str);
  req_ver = semver_split(req_ver_str);

  ret = false;
  if ver.major == req_ver.major
    if ver.minor > req_ver.minor
      ret = true;
    elseif ver.minor == req_ver.minor
      if ver.patch > req_ver.patch
        ret = true;
      elseif ver.patch == req_ver.patch
        if isempty(req_ver.pre) || req_ver.pre == '>' && ~isempty(ver.extra)
          ret = true;
        end
      end
    end
  end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function vs = semver_split(str)
rM   =       '^(?<pre>.*?)(?<major>0|[1-9]\d*)';
rMm  = [rM  '\.(?<minor>0|[1-9]\d*)'];
rMmp = [rMm '\.(?<patch>0|[1-9]\d*)'];
rMmpx = [rMmp '(?<extra>.*)$'];

if regexp(str, rMmpx)
  vs = regexp(str, rMmpx, 'names');
elseif regexp(str, rMm)
  vs = regexp(str, rMm , 'names');
elseif regexp(str, rM)
  vs = regexp(str, rM  , 'names');
end

if ~isfield(vs, 'minor') vs.minor = '0'; end
if ~isfield(vs, 'patch') vs.patch = '0'; end
if ~isfield(vs, 'extra') vs.extra = ''; end

end
