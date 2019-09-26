%  obj= relja_loadobj(obj, objStruct)
%
%  Author: Relja Arandjelovic (relja@relja.info)

function obj= relja_loadobj(obj, objStruct)
    
    for propName_= fields(objStruct)'
        propName= propName_{1};
        obj.(propName)= objStruct.(propName);
    end
    
    if isfield(objStruct, 'onGPU')
        obj.onGPU= false;
    end
    
end
