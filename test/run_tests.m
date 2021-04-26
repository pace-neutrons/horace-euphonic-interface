verify_test_data();
% Updates the required euphonic versions
curdir = split(fileparts(mfilename('fullpath')), filesep);
repodir = char(join(curdir(1:end-1), filesep));
disp(['Adding ', repodir, ' to Python path']);
append(py.sys.path, repodir);
py.euphonic_version.update_euphonic_version();

res = runtests('test/EuphonicTest.m', 'Tag', 'integration');
passed = [res.Passed];
if ~all(passed)
    quit(1);
end
