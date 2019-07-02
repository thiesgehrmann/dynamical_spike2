classdef PhaseType
% PhaseType  Enumeration of the phase types used by Dynamical.
    enumeration
        REM (3)
        NREM (2)
        SWS (2)
        WAKE (1)
    end
    
    methods
        function obj = PhaseType(code)
            obj.Code = code;
        end
    end
    
    properties
        Code
    end
end
