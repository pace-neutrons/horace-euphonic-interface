classdef force_constants < euphonic.light_python_wrapper
    % Light Matlab wrapper class around the ureg units class
    properties(Access=protected)
        pyobj = [];  % Reference to python object
        eu = [];     % Reference to euphonic module
    end
    methods
        % Constructor
        function obj = force_constants(varargin)
            py.sys.setdlopenflags(int32(10));
            obj.eu = py.importlib.import_module('euphonic');
            if ~isempty(varargin)
                args = euphonic.light_python_wrapper.parse_args(varargin, py.getattr(py.euphonic.ForceConstants, '__init__'));
                obj.pyobj = py.euphonic.ForceConstants(args{:});
                obj.populate_props();
            end
        end
    end
    methods(Static)
        function obj = from_dict(dict)
            obj = euphonic.force_constants;
            obj.pyobj = obj.eu.ForceConstants.from_dict(dict);
            obj.populate_props();
        end
        function obj = from_castep(filename)
            obj = euphonic.force_constants;
            obj.pyobj = obj.eu.ForceConstants.from_castep(filename);
            obj.populate_props();
        end
        function obj = from_json_file(filename)
            obj = euphonic.force_constants;
            obj.pyobj = obj.eu.ForceConstants.from_json(filename);
            obj.populate_props();
        end
        function obj = from_phonopy(varargin)
            args = euphonic.light_python_wrapper.parse_args(varargin, obj.eu.ForceConstants.from_phonopy);
            obj = euphonic.force_constants;
            obj.pyobj = obj.eu.ForceConstants.from_phonopy(args{:});
            obj.populate_props();
        end
    end
end



