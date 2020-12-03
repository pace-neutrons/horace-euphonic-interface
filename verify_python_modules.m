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
    catch prob
      error('euphonic_horace_interface:verify_python_modules:modVersionUnavailable',...
            'Problem obtaining %s module version string\n%s',...
            mod{:}, prob.message);
    end

    if ~semver_compatible(ver, mods.(mod{:}))
      error('euphonic_horace_interface:verify_python_modules:modIncompatibleVersion',...
            '%s >= %s required but %s present',mod{:}, mods.(mod{:}), ver);
    end
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ret = semver_compatible(astr, bstr)
a = semver_split(astr);
b = semver_split(bstr);
if a(1) == b(1) && (a(2) > b(2) || (a(2)==b(2) && a(3)>=b(3)))
  ret = true;
else
  ret = false;
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function v = semver_split(str)
rM   =       '^(?<major>0|[1-9]\d*)';
rMm  = [rM  '\.(?<minor>0|[1-9]\d*)'];
rMmp = [rMm '\.(?<patch>0|[1-9]\d*)'];

if regexp(str, rMmp)
  vs = regexp(str, rMmp, 'names');
elseif regexp(str, rMm)
  vs = regexp(str, rMm , 'names');
  vs.patch = '0';
elseif regexp(str, rM)
  vs = regexp(str, rM  , 'names');
  vs.minor = '0';
  vs.patch = '0';
end

v = structfun(@str2num, vs);
end