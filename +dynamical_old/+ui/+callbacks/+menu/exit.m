function exit(src, event) %#ok<INUSD>
% EXIT  Closes the main window to exit the program.
%
% Syntax:
% EXIT(src, event)
%
% Description:
% Callback for the File->Exit menu item.  Closes the main window which
% triggers exiting the program and any ensuing cleanup.

narginchk(2, 2);

% Close the top level (main) window.
close(src.Parent.Parent);
