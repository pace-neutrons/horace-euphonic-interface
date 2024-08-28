function [docPage, displayText, primitive] = getReferencePage(varargin)
    % Function to overload built-in "getReferencePage" function
    global web_called_with;
    web_called_with = varargin;
    displayText = string.empty;
    primitive = true;
    docPage = [];
end

