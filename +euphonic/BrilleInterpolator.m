classdef BrilleInterpolator < light_python_wrapper.light_python_wrapper
    % Matlab class around the BrilleInterpolator Python class
    % To obtain help on this class and its methods please type help(class) or help(class.method) on the command line.
    % This will bring up the Python documentation
    properties(Access=protected)
        pyobj = [];  % Reference to python object
        eu = [];     % Reference to euphonic module
    end
    methods
        % Constructor
        function obj = BrilleInterpolator(varargin)
            euphonic_on();
            light_python_wrapper.light_python_wrapper.redirect_python_warnings();
            obj.eu = py.importlib.import_module('euphonic.brille_interpolator');
            obj.helpref = obj.eu.BrilleInterpolator;
            if ~isempty(varargin)
                args = light_python_wrapper.light_python_wrapper.parse_args(...
                    varargin, py.getattr(obj.eu.BrilleInterpolator, '__init__'));
                obj.pyobj = py.euphonic.brille_interpolator.BrilleInterpolator(args{:});
                obj.populate_props();
            end
        end
    end
    methods(Static)
        function obj = from_force_constants(varargin)
            obj = euphonic.BrilleInterpolator;
            args = light_python_wrapper.light_python_wrapper.parse_args(...
                varargin, obj.eu.BrilleInterpolator.from_force_constants);
            obj.pyobj = obj.eu.BrilleInterpolator.from_force_constants(args{:});
            obj.populate_props();
        end
    end
end



