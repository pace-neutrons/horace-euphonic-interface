classdef EuphonicHelpTest < matlab.mock.TestCase
    % Tests that the help / doc functions work
    methods(Test, TestTags={'help'})
        function run_euphonic_help_tests(testCase)
            % Need to use nested function to avoid the imports
            % (Matlab runs all imports in a function before executing it,
            % and we can only run "clear import" on commandline.)
            function txt = eval_help(cmd)
                txt = evalc(cmd);
            end
            function txt = eval_help_import(cmd)
                import euphonic.help
                txt = evalc(cmd);
            end
            % Gets the text from calling Matlab help without import
            txt_fc_noimport = eval_help('help euphonic.ForceConstants');
            txt_cc_noimport = eval_help('help euphonic.CoherentCrystal');
            % Imports the function and check the output is different
            txt_fc_import = eval_help_import('help euphonic.ForceConstants');
            txt_cc_import = eval_help_import('help euphonic.CoherentCrystal');
            import matlab.unittest.constraints.IsTrue
            import matlab.unittest.constraints.IsFalse
            % Checks the two versions are different
            testCase.verifyThat(strcmp(txt_fc_noimport, txt_fc_import), IsFalse);
            testCase.verifyThat(strcmp(txt_cc_noimport, txt_cc_import), IsFalse);
            % Checks we still have hyperlinks in the imported version
            testCase.verifyThat(contains(txt_fc_import, 'href'), IsTrue);
            testCase.verifyThat(contains(txt_cc_import, 'href'), IsTrue);
            % Checks that __init__ method is included
            testCase.verifyThat(contains(txt_fc_import, '__init__'), IsTrue);
            testCase.verifyThat(contains(txt_cc_import, '__init__'), IsTrue);
        end
        function run_euphonic_doc_tests(testCase)
            % Adds the "mymockfunc" folder which has the "web" function
            % since we don't want to call the built-in version.
            mockpath = fullfile(fileparts(mfilename('fullpath')), 'mymockfuncs');
            addpath(mockpath);
            cleanup = onCleanup(@() rmpath(mockpath));
            % Nested functions to avoid imports 
            % (duplication unavoidable as imports not in scope of called functions)
            function txt = eval_doc(cmd)
                global web_called_with, web_called_with = [];
                eval(cmd);
                testCase.verifyNotEmpty(web_called_with);
                txt = web_called_with;
            end
            function txt = eval_doc_import(cmd)
                import euphonic.doc
                global web_called_with, web_called_with = [];
                eval(cmd);
                testCase.verifyNotEmpty(web_called_with);
                txt = web_called_with;
            end
            import matlab.unittest.constraints.IsTrue
            import matlab.unittest.constraints.IsFalse
            txt_fc_noimport = eval_doc('doc euphonic.ForceConstants');
            txt_fc_import = eval_doc_import('doc euphonic.ForceConstants');
            % Checks both cases called "web" with the "-helpbrowser" argument
            testCase.verifySubstring(txt_fc_noimport{2}, 'helpbrowser');
            testCase.verifySubstring(txt_fc_import{2}, 'helpbrowser');
            % Checks the two text are different
            testCase.verifyThat(strcmp(txt_fc_noimport{1}, txt_fc_import{1}), IsFalse);
            % Checks we still have hyperlinks in the imported version
            testCase.verifyThat(contains(txt_fc_import{1}, 'href'), IsTrue);
            % Checks that __init__ method is included
            testCase.verifyThat(contains(txt_fc_import{1}, '__init__'), IsTrue);
        end
    end
end
