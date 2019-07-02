classdef ParserAttribute
    enumeration
        ScalarNonEmpty ({'scalar', 'nonempty'})
        Scalar ({'scalar'})
        NonEmpty ({'nonempty'})
    end
    
    properties (SetAccess = immutable, GetAccess = private)
        Attributes cell
    end
    
    methods
        function obj = ParserAttribute(attribs)
            obj.Attributes = attribs;
        end
        
        function c = toCell(obj, varargin)
            nAttributes = length(obj);
            
            for i = 1:nAttributes
                if nargin < 2
                    extraArgs = {};
                else
                    extraArgs = varargin;
                end

                c = [cellstr(obj.Attributes), extraArgs];
            end
        end
        
%         function c = toChar(obj, extraArgs)
%             c = strjoin(obj.toCell(extraArgs), ', ');
%         end
%         
%         function s = toString(obj, extraArgs)
%             s = string(obj.toChar(extraArgs));
%         end
    end
end
