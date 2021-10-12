classdef CoherentCrystal < light_python_wrapper.light_python_wrapper
    % Matlab wrapper around a Euphonic interface Python class
    % To obtain help on this class and its methods please type help(class) or help(class.method) on the command line.
    % This will bring up the Python documentation
    properties(Access=protected)
        pyobj = [];  % Reference to python object
    end
    methods
        % Constructor
        function obj = CoherentCrystal(varargin)
            euphonic_on();
            light_python_wrapper.light_python_wrapper.redirect_python_warnings();
            eu = py.importlib.import_module('euphonic_sqw_models');
            obj.helpref = eu.CoherentCrystal;
            % Allow empty constructor for help function
            if ~isempty(varargin)
                args = light_python_wrapper.light_python_wrapper.parse_args(varargin, py.getattr(eu.CoherentCrystal, '__init__'));
                obj.pyobj = py.euphonic_sqw_models.CoherentCrystal(args{:});
                obj.populate_props();
            end
            obj.overrides = {'horace_disp'};
        end
        function out = horace_disp(self, qh, qk, ql, pars, varargin)
            % Overrides Python function to do chunking in Matlab to print messages

            % If varargin assume named arguments, pass as Python kwargs
            if ~isempty(varargin)
                kwarg_pairs = [pars, varargin];
                kwargs = pyargs(kwarg_pairs{:});
                args = {};
            else
            % If a single array of parameters, pass as positional
            % arguments
                args = num2cell(pars);
                kwargs = pyargs();
            end

            horace_disp = py.getattr(self.pyobj, 'horace_disp');
            chunk_size = double(self.pyobj.chunk);
            lqh = numel(qh);
            if self.pyobj.verbose && chunk_size > 0
                self.pyobj.chunk = 0;
                nchunk = ceil(lqh / chunk_size);
                pyout = {};
                for ii = 1:nchunk
                    qi = (ii-1)*chunk_size + 1;
                    qf = min([ii*chunk_size lqh]);
                    fprintf('Using Euphonic to interpolate for q-points %d:%d out of %d\n', qi, qf, lqh);
                    pyout = cat(1, pyout, light_python_wrapper.p2m(horace_disp(qh(qi:qf), qk(qi:qf), ql(qi:qf), args{:}, kwargs)));
                end
                self.pyobj.chunk = chunk_size;
                for jj = 1:2
                    tmp = cat(1, pyout{:,jj});
                    for ii = 1:size(tmp,2)
                        out{jj}{ii} = cell2mat(tmp(:,ii)'); %#ok<AGROW>
                    end
                end
            else
                out = light_python_wrapper.p2m(horace_disp(qh, qh, qk, args{:}, kwargs));
            end
        end
    end
end
