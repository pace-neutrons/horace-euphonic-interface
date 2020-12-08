classdef ureg < euphonic.light_python_wrapper
    % Matlab wrapper around the ureg units registry
    % To obtain help on this class and its methods please type help(class) or help(class.method) on the command line.
    % This will bring up the Python documentation
    properties(Access=protected)
        pyobj = [];  % Reference to python object
    end
    methods
        % Constructor
        function obj = ureg(unit_name)
            obj.pyobj = py.euphonic_wrapper.ureg(char(unit_name));
            obj.populate_props();
        end
        % Overloads multiply to ensure lhs/rhs formats always correct
        function out = mtimes(a, b)
            out = multiply(a, b);
        end
        function out = times(a, b)
            out = multiply(a, b);
        end
    end
    methods(Access=private)
        function out = multiply(a, b)
            if strcmp(class(a), 'ureg')
                out = a.pyobj * euphonic.m2p(b);
            else
                out = euphonic.m2p(a) * b.pyobj;
            end
        end    
    end
end



