classdef CoherentSqw < light_python_wrapper.light_python_wrapper
    % Matlab wrapper around a Euphonic interface Python class
    % To obtain help on this class and its methods please type help(class) or help(class.method) on the command line.
    % This will bring up the Python documentation
    properties(Access=protected)
        pyobj = [];  % Reference to python object
    end
    methods
        % Constructor
        function obj = CoherentSqw(varargin)
            euphonic_on();
            eu = py.importlib.import_module('horace_euphonic_interface');
            obj.helpref = eu.EuphonicWrapper;
            % Allow empty constructor for help function
            if ~isempty(varargin)
                args = light_python_wrapper.light_python_wrapper.parse_args(varargin, py.getattr(eu.EuphonicWrapper, '__init__'));
                obj.pyobj = py.horace_euphonic_interface.EuphonicWrapper(args{:});
                obj.populate_props();
            end
        end
    end
end
