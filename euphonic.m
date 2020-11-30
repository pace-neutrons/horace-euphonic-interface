classdef euphonic < light_python_wrapper
    % Light Matlab wrapper class around a Euphonic interface Python class
    properties(Access=protected)
        pyobj = [];  % Reference to python object
    end
    methods
        % Constructor
        function obj = euphonic(varargin)
            args = light_python_wrapper.parse_args(varargin, py.getattr(py.euphonic_wrapper.euphonic_wrapper, '__init__'));
            obj.pyobj = py.euphonic_wrapper.euphonic_wrapper(args{:});
            obj.populate_props();
        end
    end
    methods(Static)
        function out = mp_grid(sz)
            out = py.euphonic_wrapper.mp_grid(int32(sz));
        end
    end
end
