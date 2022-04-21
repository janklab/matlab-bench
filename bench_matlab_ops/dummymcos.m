classdef dummymcos
    %DUMMYMCOS A dummy new-style (MCOS) class
    
    %#ok<*MANU>

    properties
        foo = [];
        propWithGetter = [];
    end
    
    properties (Constant = true)
        MY_CONSTANT = [];
    end
    
    methods
        function nop(obj)
        %NOP No-op method
        end
        
        function call_private_nop(obj, nIters)
        for i = 1:nIters
            private_nop(obj);
        end
        end
        
        function out = get.propWithGetter(obj)
        out = obj.propWithGetter;
        end
    end
    
    methods (Access = private)
        function private_nop(obj)
        end
    end
    
    methods (Static = true)
        function static_nop()
        end
    end
    
end
