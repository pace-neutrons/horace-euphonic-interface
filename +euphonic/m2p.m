% brillem -- a MATLAB interface for brille
% Copyright 2020 Greg Tucker
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <https://www.gnu.org/licenses/>.

function p = m2p(m,dtype,neversqueeze)
if nargin<3 || isempty(neversqueeze) || ~islogical(neversqueeze)
    neversqueeze = false;
end
if nargin<2 || isempty(dtype) || ~ischar(dtype)
    dtype = 'double';
end

if strncmpi(dtype,'complex',min(length(dtype),7)) || any(imag(m(:))) % the only way of testing for complex numbers in MATLAB?!
    if isscalar(m)
        p = py.complex(m);
    else
%         % ! Carefull not to use m(:)' here as ' is the complex conjugate
%         % transpose (you could use m(:).', the matrix transpose)
%         p = py.numpy.array( arrayfun(@py.complex, transpose(m(:)), 'UniformOutput',false) );
%         if ndims(m)>1
%             p=p.reshape( int64(size(m)) );
%         end
        rp = euphonic.m2p( real(m) );
        ip = euphonic.m2p( imag(m) );
        p = rp + 1i*ip;
    end
else
    switch lower(dtype)
        case {'int','int64','cint'}
            p = int64(m);
        case {'uint','uint64','size_t'}
            p = uint64(m);
        otherwise
            p = m;
    end
    if ~isscalar(m) && ~ischar(m)
        if verLessThan('matlab','9.5')
            p = py.numpy.array(transpose(p(:)));
            if neversqueeze || any( size(m)~=1 & size(m)~=numel(m) )
                p=p.reshape( int64(size(m)) );
            end
        else
            p = py.numpy.array(p);
        end
    end
end

end
