classdef light_python_wrapper < dynamicprops
    % Abstract base class acting as a Matlab wrapper around a Python class
    properties(Abstract, Access=protected)
        pyobj;  % Reference to python object
    end
    properties(Access=protected)
        helpref;  % Reference to the python class for help info
        overrides = {};  % Cell of methods to override with Matlab method
    end
    methods(Static, Access=protected)
        function out = parse_args(args, fun_ref)
            % Unwraps lightly-wrapped objects
            for ii = 1:numel(args)
                if isa(args{ii}, 'euphonic.light_python_wrapper')
                    args{ii} = args{ii}.pyobj;
                end
            end
            % Convert Matlab style arguments to Python args and kwargs
            if nargin > 1
                try
                    out = parse_with_signature(args, get_signatures(fun_ref));
                catch ME
                    if strncmp(ME.message, 'Python Error: ValueError: no signature found', 44)
                        out = parse_without_signature(args);
                    else
                        rethrow(ME)
                    end
                end
            else
                out = parse_without_signature(args);
            end
        end
    end
    methods
        function [out, docTopic] = help(obj)
            % Overloads the help function for this particular object to use the Python docstring
            process = helpUtils.helpProcess(1, 1, {obj});
            if ~isempty(obj.pyobj)
                helptxt = get_help(obj.pyobj);
                if strcmp(helptxt, 'None') && ~isempty(obj.helpref)
                    helptxt = get_help(obj.helpref);
                end
            elseif ~isempty(obj.helpref)
                helptxt = get_help(obj.helpref);
            else
                helptxt = sprintf(['Python object not found.\n' ...
                                   'Please construct the object and call help on it.']);
            end
            docTopic = process.topic;
            if nargout > 0
                out = helptxt;
            else
                disp(docTopic);
                disp(helptxt);
            end
        end
        function out = disp(obj)
            % Overloads the default information Matlab displays when the object is called
            repr_fun = py.getattr(obj.pyobj, '__repr__');
            out = repr_fun();
            if nargout == 0
                disp(out);
            end
        end
        function varargout = subsref(obj, s)
            % Overloads Matlab indexing to allow users to get at Python properties directly using dot notation.
            switch s(1).type
                case '{}'
                    % Overload to allow access to hidden Python properties (starts with _ - not allowed by Matlab)
                    varargout = py.getattr(obj.pyobj, s(1).subs{1});
                    ii = 1;
                    if numel(s) > 1 && strcmp(s(2).type, '()')
                        varargout = varargout(s(2).subs);
                        ii = 2;
                    end
                    if numel(s) > ii
                        varargout = python_redirection(varargout, s((ii+1):end));
                    end
                case '.'
                    if any(cellfun(@(c) strcmp(s(1).subs, c), obj.overrides))
                        varargout = get_matlab(obj, s);
                    else
                        try
                            varargout = python_redirection(obj.pyobj, s);
                            % Try to convert output to Matlab format if possible
                            if ~strcmp(s(end).subs, 'pyobj')
                                try %#ok<TRYNC>
                                    varargout = euphonic.p2m(varargout);
                                end
                            end
                        catch ME
                            % Property is not in the Python object - must be in the Matlab object
                            if (strcmp(ME.identifier, 'MATLAB:Python:PyException') && ...
                                    ~isempty(strfind(ME.message, 'object has no attribute'))) || ...
                               strcmp(ME.message, sprintf('Object "%s" is not callable', s(1).subs))
                                varargout = get_matlab(obj, s);
                            else
                                rethrow(ME)
                            end
                        end
                    end
                case '()'
                    args = euphonic.light_python_wrapper.parse_args(s(1).subs, obj.pyobj);
                    varargout = obj.pyobj(args{:}, 'node_volume_fraction');
            end
            if ~iscell(varargout)
                varargout = {varargout};
            end
        end
    end
    methods(Access=protected)
        function props = populate_props(obj)
            props = py.dir(obj.pyobj);
            for ii = 1:double(py.len(props))
                if ~props{ii}.startswith('_')
                    % Adds property names here so tab-completion works.
                    % But actually overload subsref so call Python directly. (So matlab properties are empty.)
                    obj.addprop(props{ii}.char);
                end
            end
        end
    end
    methods(Hidden=true)
        function n = numArgumentsFromSubscript(varargin)
            % Function to override nargin/nargout for brace indexing to access hidden properties
            n = 1;
        end
        function D = addprop(obj, propname)
            D = addprop@dynamicprops(obj, propname);
        end
    end
end

function out = get_help(ref)
    out = char(py.getattr(ref, '__doc__'));
    if isa(out, 'py.NoneType')
        out = py.pydoc.render_doc(ref);
    end
end

function out = get_obj_or_class_method(obj, method, args)
% Try to get a Python object's attribute using Matlab dot notation or python getattr method
    try
        if nargin > 2
            out = obj.(method)(args{:}); 
        else
            out = obj.(method);
        end
    catch ME
        if strcmp(ME.identifier, 'MATLAB:noSuchMethodOrField') || ...
            strcmp(ME.identifier, 'MATLAB:structRefFromNonStruct') || ...
            (nargin < 3 && strcmp(ME.identifier, 'MATLAB:Python:PyException'))
            if nargin > 2
                pyobj = py.getattr(obj, method);
                out = pyobj(args{:});
            else
                out = py.getattr(obj, method);
            end            
        else
            rethrow(ME);
        end
    end
end

function out = is_simple_python(class_name)
    simple_classes = {'py.float', 'py.complex', 'py.int', 'py.long', 'py.str', ...
                      'py.bool', 'py.dict', 'py.tuple', 'py.list', ...
                      'py.unicode', 'py.bytes', 'py.array.array'};
	out = any(cellfun(@(c) strcmp(class_name, c), simple_classes));
end

function objs = wrap_python(objs)
% Wraps a cell of Python objects in a light wrapper, unless they are base python types
% This allows the overload help function to work
    for ii = 1:numel(objs)
        if strncmp(class(objs{ii}), 'py.', 3) && ~is_simple_python(class(objs{ii}))
            objs{ii} = euphonic.generic_python_wrapper(objs{ii});
        end
    end
end

function varargout = python_redirection(first_obj, s)
    % Function to parse a subsref indexing structure and return recursively the desired python property
    ii = 1;
    varargout = first_obj;
    dont_wrap = false;
    help_not_called = true;
    while ii <= numel(s)
        if s(ii).type == '.'
            if numel(s) > ii && strcmp(s(ii+1).type, '()')
                args = euphonic.light_python_wrapper.parse_args(s(ii+1).subs, py.getattr(varargout, s(ii).subs));
                varargout = get_obj_or_class_method(varargout, s(ii).subs, args);
                ii = ii + 2;
            elseif strcmp(s(ii).subs, 'pyobj')
                dont_wrap = true;
                ii = ii + 1;
            elseif strcmp(s(ii).subs, 'help') && help_not_called
                % Fails silently, and return to previous behaviour
                % (including any error that would have occured).
                try %#ok<TRYNC>
                    mat_obj = wrap_python({varargout});
                    varargout = help(mat_obj{1});
                    ii = ii + 1;
                end
                help_not_called = false;
            else
                varargout = get_obj_or_class_method(varargout, s(ii).subs);
                ii = ii + 1;
            end
        elseif strcmp(s(ii).type, '{}')
            attribute = py.getattr(varargout, s(ii).subs{1});
            if numel(s) > ii && strcmp(s(ii+1).type, '()')
                args = euphonic.light_python_wrapper.parse_args(s(ii+1).subs, attribute);
                varargout = attribute(args{:});
                ii = ii + 2;
            else
                varargout = attribute;
                ii = ii + 1;
            end
        else
            for ii = 1:numel(s); disp(s(ii)); end
            error('Syntax error: euphonic wrapper indexing error');
        end
    end
    if ~iscell(varargout)
        varargout = {varargout};
    end
    if ~dont_wrap
        varargout = wrap_python(varargout);
    end
end

function out = get_matlab(obj, s)
    if numel(s) > 1 && strcmp(s(2).type, '()')
        out = obj.(s(1).subs)(s(2).subs{:});
    else
        out = obj.(s(1).subs);
    end
end

function [kw_args, remaining_args] = get_kw_args(args)
    % Finds the keyword arguments (string, val) pairs, assuming that they always at the end (last 2n items)
    first_kwarg_id = numel(args) + 1;
    for ii = (numel(args)-1):-2:1
        if (ischar(args{ii}) || isstring(args{ii})) && ...
            strcmp(regexp(args{ii}, '^[A-Za-z_][A-Za-z0-9_]*', 'match'), args{ii})
            % Python identifiers must start with a letter or _ and can contain charaters, numbers or _
            first_kwarg_id = ii;
        else
            break;
        end
    end
    if first_kwarg_id < numel(args)
        kw_args = args(first_kwarg_id:end);
        remaining_args = args(1:(first_kwarg_id-1));
    else
        kw_args = {};
        remaining_args = args;
    end
end

function sig_struct = get_signatures(fun_ref)
    % Use Python's inspect module to get the function signature for a Python function
    fun_sig = py.inspect.signature(fun_ref);
    pars = fun_sig.parameters.struct;
    fn = fieldnames(pars);
    sigs = struct();
    for ii = 1:numel(fn)
        par = pars.(fn{ii});
        sigs(ii).name = par.name.char;
        sigs(ii).kind = par.kind.char;
        sigs(ii).default = par.default;
        sigs(ii).annotation = par.annotation;
        if isa(par.default, 'py.type')
            sigs(ii).has_default = ~strcmp(par.default.char, "<class 'inspect._empty'>");
        else
            sigs(ii).has_default = true;
        end
    end
    if strcmp(sigs(1).name, 'self')
        sigs(1) = [];
    end
    % Now infer properties about the arguments. Python rules are:
    % 1. Must have named POSITIONAL_ONLY or POSITIONAL_OR_KEYWORD args first.
    % 2. Args with default values must follow args without default values.
    % 3. *args (VAR_POSITIONAL) must follow all named positional args
    % 4. Args after *args are KEYWORD_ONLY
    % 5. **kwargs (VAR_KEYWORD) must be last
    sig_struct.first_default = find(cellfun(@(x)x, {sigs.has_default}), 1, 'first');
    if isempty(sig_struct.first_default)
        sig_struct.first_default = numel(sigs) + 1;
    end
    sig_struct.has_kwargs = strcmp(sigs(end).kind, 'VAR_KEYWORD');
    sig_struct.has_args = false;
    sig_struct.last_pos_index = 0;
    sig_struct.pos_only_args = [];
    for ii = 1:numel(sigs)
        if strcmp(sigs(ii).kind, 'VAR_POSITIONAL')
            sig_struct.has_args = true;
        elseif strcmp(sigs(ii).kind, 'POSITIONAL_ONLY')
            sig_struct.pos_only_args = [sig_struct.pos_only_args ii];
            sig_struct.last_pos_index = ii;
        elseif strcmp(sigs(ii).kind, 'POSITIONAL_OR_KEYWORD')
            sig_struct.last_pos_index = ii;
        end
    end
    sig_struct.kw_only_args = find(cellfun(@(c) strcmp(c, 'KEYWORD_ONLY'), {sigs.kind}));
    sig_struct.sigs = sigs;
end

function out = get_correct_type(pname, pval, sigs)
    % Looks through Python signatures and converts Matlab types of correct Python types 
    sigidx = find(cellfun(@(c) strcmp(pname, c), {sigs.name}));
    py_type = class(sigs(sigidx).default);
    out = pval;
    if is_simple_python(py_type)
        if strcmp(py_type, 'py.int') || strcmp(py_type, 'py.long')
            out = int64(pval);
        end
    end
end

function out = parse_with_signature(args, signatures)
    % Convert Matlab style arguments to Python with information from the Python function signature
    named_args = {signatures.sigs([1:signatures.last_pos_index signatures.kw_only_args]).name};
    % Look for named keywords pairs in input arguments
	ii = 1;
    args_kw = {};
    args_remaining = {};
    while ii <= numel(args)
        if any(cellfun(@(c) strcmp(c, args{ii}), named_args))
            args_kw{end+1} = args{ii};
            args_kw{end+1} = get_correct_type(args{ii}, args{ii+1}, signatures.sigs);
            ii = ii + 1;
        else
            args_remaining{end+1} = args{ii};
        end
        ii = ii + 1;
    end    
    % Determine the named arguments which the user has not given as keyword arguments
    missing_args = setdiff(named_args, args_kw(1:2:end));
    [~, ~, missing_args_index] = intersect(missing_args, {signatures.sigs.name});
    % The first set of consecutive missing arguments must be in the positional arguments list
    consecutive_args = find((sort(missing_args_index(:)') - [1:numel(missing_args_index)]) == 0, 1, 'last');
    first_args = min(consecutive_args, signatures.first_default - 1);
    if isempty(consecutive_args); consecutive_args = 0; end
    if isempty(first_args); first_args = 0; end
    args_pos = {};
    if numel(args_remaining) >= first_args
        % Assume that they are positional arguments
        args_pos = args_remaining(1:first_args);
        args_remaining = args_remaining((first_args+1):end);
        n_args_remain = first_args;
    else
        n_args_remain = min(first_args, numel(args_remaining));
    end
    % Determine if there are any arguments without default values which are missing.
    missing_defaults = sort(missing_args_index);
    missing_defaults(1:n_args_remain) = [];
    missing_defaults(missing_defaults >= signatures.first_default) = [];
    if ~isempty(missing_defaults)
        error('Required arguments "%s" missing', join(string({signatures.sigs(missing_defaults).name}), ', '));
    end
    if signatures.has_kwargs
        % Count back from end and check if any strings are allowed Python identifiers
        % If so, assume they are keyword arguments.
        [kw_args_remaining, args_remaining] = get_kw_args(args_remaining);
        args_kw = [args_kw, kw_args_remaining];
    end
    % The remaining arguments are probably positional arguments with default values
    if numel(args_remaining) > 0
        args_end = min(consecutive_args - first_args, numel(args_remaining));
        args_pos = [args_pos, args_remaining(1:args_end)];
        args_remaining = args_remaining((args_end+1):end);
    end
    if signatures.has_args
        % Everything left must be the positional arguments tuple if that's allowed
        args_pos = [args_pos, args_remaining];
    elseif numel(args_remaining) > 0
        error('Unknown arguments: %s', join(string(args_remaining), ', '));
    end

    if ~isempty(args_kw)
        out = [args_pos(:)' {pyargs(args_kw{:})}];
    else
        out = args_pos;
    end
end

function out = parse_without_signature(args)
    [kw_args, remaining_args] = get_kw_args(args);
    if ~isempty(kw_args)
        out = [remaining_args(:)' {pyargs(kw_args{:})}];
    else
        out = remaining_args;
    end
end
