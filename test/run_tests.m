function run_tests(varargin)
  % Ensure test data from euphonic_sqw_models is present
  verify_test_data();

  import matlab.unittest.TestSuite
  import matlab.unittest.TestRunner
  import matlab.unittest.plugins.CodeCoveragePlugin
  import matlab.unittest.plugins.codecoverage.CoberturaFormat
  import matlab.unittest.selectors.HasTag
  import matlab.unittest.plugins.XMLPlugin

  % Collect and run tests
  suite = TestSuite.fromFolder(pwd);
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
  runner = TestRunner.withTextOutput;

  % Add coverage output
  cov_dirs = {'+euphonic', 'euphonic_sqw_models', '+light_python_wrapper'};
  % Use full path to installed dirs
  horeuif_path = fileparts(fileparts(which('euphonic.ForceConstants')));

  for i = 1:length(cov_dirs)
      reportFormat = CoberturaFormat(fullfile(pwd, ['coverage_', cov_dirs{i}, '.xml']));
      coverage_plugin = CodeCoveragePlugin.forFolder(fullfile(horeuif_path, cov_dirs{i}), ...
                                                     'Producing', reportFormat, ...
                                                     'IncludingSubfolders', true);
      runner.addPlugin(coverage_plugin);
      if verLessThan('matlab', '9.12') % Can add cov for multiple folders only from R2022a
          break;
      end
  end

  % Add JUnit output - unique name so they are not overwritten on CI
  junit_fname = ['junit_report_', computer, version('-release'), '.xml'];
  junit_plugin = XMLPlugin.producingJUnitFormat(junit_fname);
  runner.addPlugin(junit_plugin);

  result = runner.run(suite)
  if(any(arrayfun(@(x) x.Failed, result)))
      error('Test failed');
  end