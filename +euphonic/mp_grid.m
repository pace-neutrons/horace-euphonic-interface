classdef mp_grid < light_python_wrapper.light_python_wrapper
    % Returns a Monkhorst-Pack grid of specified size
    % To obtain help on this function please type:
    %
    %   >> import euphonic.doc
    %   >> doc euphonic.mp_grid
    %
    % Or:
    %
    %   >> import euphonic.help
    %   >> help euphonic.mp_grid
    %
    % This will bring up the Python documentation
    properties(Access=protected)
        pyobj = [];  % Reference to python object
        classname = 'euphonic.util.mp_grid';
    end
    properties (Constant, Hidden)
        is_initialised = euphonic_on();
    end
    methods
        % Constructor
        function obj = mp_grid(sz)
            if nargin > 0
                obj.pyobj = py.euphonic.util.mp_grid(int32(sz));
            else
                eu = py.importlib.import_module('euphonic.util');
                obj.pyobj = py.getattr(eu, 'mp_grid');
            end
            obj.populate_props();
        end
    end
end
