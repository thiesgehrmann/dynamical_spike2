function csim = similarity(window1, window2)
% SIMILARITY
%
% Syntax:
%
% Description:
%
% Input:
% AMDWindow1
% AMDWindow2
%
% Output:
% csim

narginchk(2, 2);

% Get the number of windows to process in each list and make sure they are
% the same.
nWindows = length(window1);
assert(nWindows == length(window2), 'dynamical:math:similarity', ...
    'Window list 1 and 2 must contain the same number of elements.');

csim = zeros(1, nWindows);

% Loop over the windows lists and calculating similarity for each pair.
for i = 1:nWindows
    % Create a map from the cell ID to the name of the neurons.
    t1 = table(window1(i).NeuronNames, window1(i).Stats.CellID, 'VariableNames', {'name' 'id'});
    t2 = table(window2(i).NeuronNames, window2(i).Stats.CellID, 'VariableNames', {'name' 'id'});
    neuronMap = unique(sortrows([t1;t2], 'id'));
    nNeurons = height(neuronMap);
    
    M1 = array2table(zeros(nNeurons), 'VariableNames', neuronMap.name, 'RowNames', neuronMap.name);
    M2 = M1;
    
    [~, iw1] = ismember(window1(i).NeuronNames, neuronMap.name);
    [~, iw2] = ismember(window2(i).NeuronNames, neuronMap.name);
    
    M1(iw1, iw1) = window1(i).ZScore;
    M2(iw2, iw2) = window2(i).ZScore;
    
    % Remove the diagonal.
    j = 1:nNeurons+1:numel(M1{:,:});
    simVector1 = M1{:,:};
    simVector1(j) = [];
    simVector2 = M2{:,:};
    simVector2(j) = [];
    
    csim(i) = dot(simVector1, simVector2) / sqrt(dot(simVector1, simVector1) * dot(simVector2, simVector2));
end
