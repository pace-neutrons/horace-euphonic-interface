classdef ForceConstants < light_python_wrapper.light_python_wrapper
    % Matlab class around the ForceConstants Python class
    % To obtain help on this class and its methods please type help(class) or help(class.method) on the command line.
    % This will bring up the Python documentation
    properties(Access=protected)
        pyobj = [];  % Reference to python object
        eu = [];     % Reference to euphonic module
    end
    methods
        % Constructor
        function obj = force_constants(varargin)
            obj.eu = py.importlib.import_module('euphonic');
            obj.helpref = obj.eu.ForceConstants;
            if ~isempty(varargin)
                args = light_python_wrapper.light_python_wrapper.parse_args(varargin, py.getattr(obj.eu.ForceConstants, '__init__'));
                obj.pyobj = py.euphonic.ForceConstants(args{:});
                obj.populate_props();
            end
        end
    end
    methods(Static)
        function obj = from_dict(dict)
            obj = euphonic.ForceConstants;
            obj.pyobj = obj.eu.ForceConstants.from_dict(dict);
            obj.populate_props();
        end
        function obj = from_castep(filename)
            obj = euphonic.ForceConstants;
            obj.pyobj = obj.eu.ForceConstants.from_castep(filename);
            obj.populate_props();
        end
        function obj = from_json_file(filename)
            obj = euphonic.ForceConstants;
            obj.pyobj = obj.eu.ForceConstants.from_json(filename);
            obj.populate_props();
        end
        function obj = from_phonopy(varargin)
            obj = euphonic.ForceConstants;
            args = light_python_wrapper.light_python_wrapper.parse_args(varargin, obj.eu.ForceConstants.from_phonopy);
            obj.pyobj = obj.eu.ForceConstants.from_phonopy(args{:});
            obj.populate_props();
        end
    end
end



