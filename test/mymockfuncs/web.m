function varargout = web(varargin)
    % Function to overload built-in "web" function
    % because Matlab does not allow to mock pure functions (only classes/methods)
    varargout = {};
    global web_called_with;
    web_called_with = varargin;
end
