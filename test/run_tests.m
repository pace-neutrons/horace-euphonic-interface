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

% Install horace-euphonic-interface mltbx
toolboxes = matlab.addons.toolbox.installedToolboxes;
for i = 1:length(toolboxes)
  if strcmp(toolboxes(i).Name, 'horace_euphonic_interface')
    matlab.addons.toolbox.uninstallToolbox(toolboxes(i));
    break;
  end
end
matlab.addons.toolbox.installToolbox(...
  ['..' filesep 'mltbx' filesep 'horace_euphonic_interface.mltbx']);
matlab.addons.toolbox.installedToolboxes

% Set flags on Linux to avoid segfault with libraries
if ~ispc
  py.sys.setdlopenflags(int32(10))
end

% Ensure test data from euphonic_sqw_models is present
verify_test_data();

% Run tests
res = runtests(pwd, 'Tag', 'integration');
res2 = runtests(pwd, 'Tag', 'help');
passed = [res.Passed res2.Passed];
if ~all(passed)
    quit(1);
end
