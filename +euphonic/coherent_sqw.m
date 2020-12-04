classdef coherent_sqw < euphonic.light_python_wrapper
    % Light Matlab wrapper class around a Euphonic interface Python class
    properties(Access=protected)
        pyobj = [];  % Reference to python object
    end
    methods
        % Constructor
        function obj = coherent_sqw(varargin)
            eu = py.importlib.import_module('euphonic_wrapper');
            args = euphonic.light_python_wrapper.parse_args(varargin, py.getattr(eu.EuphonicWrapper, '__init__'));
            obj.pyobj = py.euphonic_wrapper.EuphonicWrapper(args{:});
            obj.populate_props();
        end
    end
end
