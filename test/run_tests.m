res = runtests('test/EuphonicTest.m', 'Tag', 'integration');
passed = [res.Passed];
if ~all(passed)
    quit(1);
end
