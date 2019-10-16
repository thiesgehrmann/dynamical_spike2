function final = load_struct(filename)

    S = load(filename);
    assert(isstruct(S), 'dynamical_inputs:mat:load_struct:FileOpenError', "The file does not contain a struct.");

    final = struct();

    snames = fieldnames(S);
    for fname = snames
        field = getfield(S, fname{1});
        if not(istable(field))
            continue;
        end

        colnames = fieldnames(field);
        if any(strcmp(colnames, 'Start')) & any(strcmp(colnames, 'End')) & isstruct(field)
            final.intervals = field;
        elseif any(strcmp(colnames, 'name')) & any(strcmp(colnames, 'varVersion')) & any(strcmp(colnames, 'wireNumber')) & any(strcmp(colnames, 'unitNumber')) & any(strcmp(colnames, 'xPos')) & any(strcmp(colnames, 'yPos')) & any(strcmp(colnames, 'timestamps')) & istable(field)
            final.neurondata = field;
        end


    end

    assert(any(strcmp(fieldnames(final),'neurondata')), "dynamical_inputs:mat:load_struct:NoNeuronData", "There was no neurondata table in the struct. Unable to proceed.")

    if not(any(strcmp(fieldnames(final),'intervals')))
        final.intervals = struct();
        final.intervals.Start = [];
        final.intervals.End   = [];
        final.intervalnames   = "Interval_" + [];
    end

    if size(final.intervals.Start,1) > 0
        final.intervalnames = "Interval_" + (1:size(final.intervals.Start,1));
    end

    final.intervalnames(size(final.intervalnames, 1)+1) = 'AllFile';

    final.intervals.Start    = [ final.intervals.Start ; min(cellfun(@min, final.neurondata.timestamps)) ];
    final.intervals.End      = [ final.intervals.End, max(cellfun(@max, final.neurondata.timestamps)) ];
    final.intervals.Duration = final.intervals.End - final.intervals.Start;
    final.intervals          = struct2table(final.intervals);

end