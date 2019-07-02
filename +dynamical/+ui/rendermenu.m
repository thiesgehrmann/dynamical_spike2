function handles = rendermenu(parent, menuConfigFile)
% RENDERMENU  Renders the menu for the main window.
%
% Syntax:
% handles = RENDERMENU(parent, menuConfigFile)
%
% Description:
% Creates the menu system for the main Dynamical window.  General structure
% of the menu is defined by the menuconfig.yaml file resident in the
% dynamical.ui.config package.
%
% Input:
% parent (matlab.ui.Figure) - Handle to the main dynamical window, but
%     could in theory be another figure.
% menuConfigFile (string) - The name of the YAML config file defining the
%     menu.
%
% Output:
% handles (struct) - The current handles data as returned by guihandles on
%     on the specified parent figure, but updated with the handles for each
%     menu item.

narginchk(2, 2);

% Get the current handles structure associated with the parent figure.
handles = guidata(parent);

% Read the menu config file.
configData = yaml.ReadYaml(menuConfigFile);

% Recursively add all menus to the figure.
handles = addmenus(parent, handles, configData);

% Update 'handles' attached to the parent figure.
guidata(parent, handles);


function handles = addmenus(parent, handles, siblingMenus)
menuList = fieldnames(siblingMenus);
nMenus = numel(menuList);

for i = 1:nMenus
    % Pull out some menu variables for easier readibility and access.
    m = menuList{i};
    menuTag = siblingMenus.(m).tag;
    menuLabel = siblingMenus.(m).label;
    
    % Create the menu item.
    handles.(menuTag) = uimenu(parent, 'Label', menuLabel, 'Tag', menuTag);
    
    % If a callback was specified, add it here.
    if isfield(siblingMenus.(m), 'callback') && ~isempty(siblingMenus.(m).callback)
        handles.(menuTag).Callback = str2func(siblingMenus.(m).callback);
    end
    
    % Add the accelerator if specified.
    if isfield(siblingMenus.(m), 'accelerator') && ~isempty(siblingMenus.(m).accelerator)
        handles.(menuTag).Accelerator = siblingMenus.(m).accelerator;
    end
    
    % If the menu item has a 'submenu' field, we call the addmenus function
    % again, but this time on the contents of the 'submenu' field.
    if isfield(siblingMenus.(m), 'submenu')
        handles = addmenus(handles.(menuTag), handles, siblingMenus.(m).submenu);
    end
end
