verify_test_data();
% Updates the required euphonic versions
curdir = split(fileparts(mfilename('fullpath')), filesep);
append(py.sys.path, char(join(curdir(1:end-1), filesep)));
py.euphonic_version.update_euphonic_version();
res = runtests('test/EuphonicTest.m', 'Tag', 'integration');
passed = [res.Passed];
if ~all(passed)
    quit(1);
end
