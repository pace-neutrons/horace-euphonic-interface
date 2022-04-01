function run_tests(varargin)
  % Ensure test data from euphonic_sqw_models is present
  verify_test_data();

  % Collect and run tests
  import matlab.unittest.selectors.HasTag
  suite = matlab.unittest.TestSuite.fromFolder(pwd);
  % Skip tests which generate test data
  suite = suite.selectIf(~HasTag('generate'));
  not_tag = false;
  for i = 1:length(varargin)
      if strcmp(varargin{i}, 'not')
          not_tag = true;
          continue
      else
          if not_tag
              suite = suite.selectIf(~HasTag(varargin{i}));
              not_tag = false;
          else
              suite = suite.selectIf(HasTag(varargin{i}));
          end
      end
  end
  results = run(suite);

  % Get results
  passed = [];
  for i = 1:length(results)
      passed(i) = results(i).Passed;
  end
  if ~all(passed)
      quit(1);
  end
end
