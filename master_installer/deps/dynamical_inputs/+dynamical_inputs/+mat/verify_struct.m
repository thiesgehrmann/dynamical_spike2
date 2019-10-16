function pass = verify_struct(S)
    assert(isstruct(S), "dynamical_inputs:mat:verify_struct:NotStruct", "The data is not a struct")
    assert(any(strcmp(fieldnames(S), 'neurondata')), "dynamical_inputs:mat:verify_struct:MissingData", "There was no table with neurondata available.")
    assert(istable(S.neurondata), "dynamical_inputs:mat:verify_struct:Invalid", "The structure is invalid.")

    pass = true;
end