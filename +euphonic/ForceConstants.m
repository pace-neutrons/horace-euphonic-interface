classdef ForceConstants < light_python_wrapper.light_python_wrapper
    % Matlab class around the ForceConstants Python class
    % To obtain help on this class and its methods please type help(class) or help(class.method) on the command line.
    % This will bring up the Python documentation
    properties(Access=protected)
        pyobj = [];  % Reference to python object
        classname = 'euphonic.ForceConstants'; 
    end
    methods
        % Constructor
        function obj = ForceConstants(varargin)
            if ~isempty(varargin)
                args = light_python_wrapper.light_python_wrapper.parse_args(varargin, py.getattr(obj.eu.ForceConstants, '__init__'));
                obj.pyobj = py.euphonic.ForceConstants(args{:});
            else
                eu = py.importlib.import_module('euphonic');
                obj.pyobj = py.getattr(eu, 'ForceConstants');
            end
            obj.populate_props();
        end
    end
    % Constant properties are evaluated when the *class* is loaded in
    % memory, rather than when an object is constructed.
    properties (Constant, Hidden)
        is_initialised = euphonic_on();
        is_redirected = light_python_wrapper.light_python_wrapper.redirect_python_warnings();
    end
    properties (Constant)
        from_dict = get_pymeth_ref('from_dict')
        from_castep = get_pymeth_ref('from_castep');
        from_json_file = get_pymeth_ref('from_json_file');
        from_phonopy = get_pymeth_ref('from_phonopy');
    end
end

function out = get_pymeth_ref(method_name)
    persistent eu_mod
    if isempty(eu_mod), eu_mod = py.importlib.import_module('euphonic'); end
    ref = py.getattr(eu_mod.ForceConstants, method_name);
    out = light_python_wrapper.generic_python_wrapper(ref);
end
