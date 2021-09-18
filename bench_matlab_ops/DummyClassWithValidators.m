classdef DummyClassWithValidators
    
    properties
        aWhatever
        aDouble double
        aScalarDouble (1,1) double
        aFcnValidator (1,1) double {mustBeFinite(aFcnValidator)}
    end
    
end

