% Set up Python
py_ex_path = getenv('PYTHON_EX_PATH');
disp(py_ex_path)
try
  % Pyenv only introduced in 2019b
  pyenv('Version', py_ex_path)
catch ME
  if (strcmp(ME.identifier,'MATLAB:UndefinedFunction'))
    % Pyversion is deprecated but use if pyenv not available
    pyversion(py_ex_path)
  else
    rethrow(ME);
  end
end

% Add horace-euphonic-interface to Path
addpath('..')
addpath('../light_python_wrapper')

% Set flags on Linux to avoid segfault with libraries
if ~ispc
  py.sys.setdlopenflags(int32(10))
end

% Ensure test data from euphonic_sqw_models is present
verify_test_data();

% Updates the required euphonic versions
curdir = split(fileparts(mfilename('fullpath')), filesep);
repodir = char(join(curdir(1:end-1), filesep));
disp(['Adding ', repodir, ' to Python path']);
append(py.sys.path, repodir);
py.euphonic_version.update_euphonic_version();

res = runtests("test/", 'Tag', 'integration');
passed = [res.Passed];
if ~all(passed)
    quit(1);
end
