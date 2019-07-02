function parent = parseuifile(uiFile, parent, prefix)
% PARSEUIFILE  Parses a YAML formated file to construct a UIX GUI.
%
% Syntax:
% PARSEUIFILE(uiFile)
% PARSEUIFILE(___, parent)
%
% Description:
% Parses a GUI spec contained in the specifed UI file and renders it.
% Provides a convenient way to construct UIX powered UIs without having to
% spend much time coding.
%
% Input:
% uiFile (string) - The name of the UI file to process.
% parent (handle) - Parent UI object.  If none is specified, then a new
%     figure window is created and made the parent object.

narginchk(1, 3);

if ~exist('parent', 'var') || isempty(parent)
    parent = figure;
end

if ~exist('prefix', 'var')
    prefix = '';
end

% Read the UI file.
uiData = yaml.ReadYaml(uiFile);

% Pass the UI data to the object parser.  The object parser will loop over
% the UI hierarchy and create each object found.  This function is
% recursive, so it will call itself until the entire object tree is
% exhausted.
parseobjects(uiData, parent, prefix);


function parseobjects(uiData, parent, prefix)
% Get a list of objects found in the UI data.
objectNames = fieldnames(uiData);
nObjects = length(objectNames);

% Loop over each object to process its entry and to call parseobjects again
% if the object is a container object with children.
for i = 1:nObjects
    objectName = objectNames{i};
    objectType = uiData.(objectName).type;
    
    isRef = false;
    
    % Create the object depending on its type.
    switch objectType
        case {'HBox', 'VBox', 'Empty'}
            hObject = feval(sprintf('uix.%s', objectType), 'Parent', parent);
        case 'control'
            hObject = feval('uicontrol', 'Parent', parent);
        case 'ref'
            isRef = true;
        otherwise
            error('Invalid object type: %s', objectType)
    end
    
    % If the object is a reference to another UI file, then we'll need to
    % parse the referenced UI file.  If it's a regular inline object spec,
    % process its properties.
    if isRef
        if isfield(uiData.(objectName), 'params') && ...
            isfield(uiData.(objectName).params, 'tagPrefix') && ...
            ~isempty(uiData.(objectName).params.tagPrefix)
            if isempty(prefix)
                combinedPrefix = uiData.(objectName).params.tagPrefix;
            else
                combinedPrefix = sprintf('%s_%s', prefix, uiData.(objectName).params.tagPrefix);
            end
        else
            combinedPrefix = prefix;
        end
        
        sourceData = yaml.ReadYaml(uiData.(objectName).source);
        parseobjects(sourceData, parent, combinedPrefix);
    else
        % If the object has children, then we need to recursively call
        % parseobjects on the children hierarchy.
        if isfield(uiData.(objectName), 'children')
            parseobjects(uiData.(objectName).children, hObject, prefix);
        end
        
        % If the object has a 'params' field, then it has properties that need
        % to be set.  Each field found within params should be a key/value pair
        % with the field name being the key name and its contents being the
        % value.
        if isfield(uiData.(objectName), 'params')
            params = fieldnames(uiData.(objectName).params);
            
            for iParam = 1:length(params)
                prop = params{iParam};
                value = uiData.(objectName).params.(prop);
                
                % Arrays take the form of a cell array of individual
                % numbers.  Convert to the standard array form if
                % necessary.
                if iscell(value) && isvector(value)
                    value = cellfun(@(x) x, value);
                end
                
                hObject.(prop) = value;
            end
        end
        
        if isempty(hObject.Tag)
            hObject.Tag = objectName;
        end
        
        % Prefix the tag name if specified.
        if ~isempty(prefix)
            hObject.Tag = sprintf('%s_%s', prefix, hObject.Tag);
        end
    end
end
