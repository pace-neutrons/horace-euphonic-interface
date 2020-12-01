classdef ureg < euphonic.light_python_wrapper
    % Light Matlab wrapper class around the ureg units class
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
                out = a.pyobj * m2p(b);
            else
                out = m2p(a) * b.pyobj;
            end
        end    
    end
end



