function abspath = get_abspath(filename, sub_dir)
    % Get absolute path to a file in the test directory
    s = what('test');
    test_dir = s.path;
    abspath =  [test_dir filesep sub_dir filesep filename];
end