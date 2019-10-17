function pass = verify_struct(S)
		if not(isstruct(S))
			pass = false;
		elseif not(any(strcmp(fieldnames(S), 'neurondata')))
			pass = false;
		elseif not(istable(S.neurondata))
			pass = false;
		else
			pass = true;
		end
