%  objStruct= relja_saveobj(obj)
%
%  Author: Relja Arandjelovic (relja@relja.info)

function objStruct= relja_saveobj(obj)
    
    objStruct= {};
    
    for propName_= properties(obj)'
        propName= propName_{1};
        objStruct.(propName)= gather( obj.(propName) );
    end
    
    if isfield(objStruct, 'onGPU')
        objStruct.onGPU= false;
    end
    
end
