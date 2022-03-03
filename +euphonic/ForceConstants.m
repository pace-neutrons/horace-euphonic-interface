classdef ForceConstants < light_python_wrapper.light_python_wrapper
    % Matlab class around the ForceConstants Python class
    % To obtain help on this class and its methods please type:
    %
    %   >> import euphonic.doc
    %   >> doc euphonic.ForceConstants
    %
    % Or:
    %
    %   >> import euphonic.help
    %   >> help euphonic.ForceConstants
    %
    % This will bring up the Python documentation
    properties(Access=protected)
        pyobj = [];  % Reference to python object
        eu = [];     % Reference to euphonic module
        classname = 'euphonic.ForceConstants'; 
    end
    properties (Hidden)
        is_initialised = euphonic_on();
        is_redirected = light_python_wrapper.light_python_wrapper.redirect_python_warnings();
    end
    methods
        % Constructor
        function obj = ForceConstants(varargin)
            obj.eu = py.importlib.import_module('euphonic');
            if ~isempty(varargin)
                args = light_python_wrapper.light_python_wrapper.parse_args(varargin, py.getattr(obj.eu.ForceConstants, '__init__'));
                obj.pyobj = py.euphonic.ForceConstants(args{:});
            else
                obj.pyobj = py.getattr(obj.eu, 'ForceConstants');
            end
            obj.populate_props();
        end
    end
    methods (Static)
        function obj = from_dict(dict)
            % Convert a dictionary (Matlab structure) to a ForceConstants object
            % To obtain help on this method, type:
            %   >> import euphonic.help; help euphonic.ForceConstants.from_dict
            obj = euphonic.ForceConstants;
            obj.pyobj = obj.eu.ForceConstants.from_dict(dict);
            obj.populate_props();
        end
        function obj = from_castep(filename)
            % Reads from a .castep_bin or .check file
            % To obtain help on this method, type:
            %   >> import euphonic.help; help euphonic.ForceConstants.from_castep
            obj = euphonic.ForceConstants;
            obj.pyobj = obj.eu.ForceConstants.from_castep(filename);
            obj.populate_props();
        end
        function obj = from_json_file(filename)
            % Read from a JSON file
            % To obtain help on this method, type:
            %   >> import euphonic.help; help euphonic.ForceConstants.from_json_file
            obj = euphonic.ForceConstants;
            obj.pyobj = obj.eu.ForceConstants.from_json(filename);
            obj.populate_props();
        end
        function obj = from_phonopy(varargin)
            % Reads data from the phonopy summary file (default: phonopy.yaml)
            % To obtain help on this method, type:
            %   >> import euphonic.help; help euphonic.ForceConstants.from_phonopy
            obj = euphonic.ForceConstants;
            args = light_python_wrapper.light_python_wrapper.parse_args(varargin, obj.eu.ForceConstants.from_phonopy);
            obj.pyobj = obj.eu.ForceConstants.from_phonopy(args{:});
            obj.populate_props();
        end
    end
end
