classdef BrilleInterpolator < light_python_wrapper.light_python_wrapper
    % Matlab class around the BrilleInterpolator Python class
    % To obtain help on this class and its methods please type:
    %
    %   >> import euphonic.doc
    %   >> doc euphonic.BrilleInterpolator
    %
    % Or:
    %
    %   >> import euphonic.help
    %   >> help euphonic.BrilleInterpolator
    %
    % This will bring up the Python documentation
    properties(Access=protected)
        pyobj = [];  % Reference to python object
        eubr = [];     % Reference to euphonic.brille module
        classname = 'euphonic.brille.BrilleInterpolator';
    end
    % Constant properties are evaluated when the *class* is loaded in
    % memory, rather than when an object is constructed.
    properties (Constant, Hidden)
        is_initialised = euphonic_on();
        is_redirected = light_python_wrapper.light_python_wrapper.redirect_python_warnings();
    end
    methods
        % Constructor
        function obj = BrilleInterpolator(varargin)
            obj.eubr = py.importlib.import_module('euphonic.brille');
            if ~isempty(varargin)
                args = light_python_wrapper.light_python_wrapper.parse_args(...
                    varargin, py.getattr(obj.eubr.BrilleInterpolator, '__init__'));
                obj.pyobj = py.euphonic.brille.BrilleInterpolator(args{:});
            else
                obj.pyobj = py.getattr(obj.eubr, 'BrilleInterpolator');
            end
            obj.populate_props();
        end
    end
    methods(Static)
        function obj = from_force_constants(varargin)
            % Creates a BrilleInterpolator object from a ForceConstants object
            % To obtain help on this method, type:
            %   >> import euphonic.help; help euphonic.BrilleInterpolator.from_force_constants
            obj = euphonic.BrilleInterpolator;
            args = light_python_wrapper.light_python_wrapper.parse_args(...
                varargin, obj.eubr.BrilleInterpolator.from_force_constants);
            obj.pyobj = obj.eubr.BrilleInterpolator.from_force_constants(args{:});
            obj.populate_props();
        end
    end
end
