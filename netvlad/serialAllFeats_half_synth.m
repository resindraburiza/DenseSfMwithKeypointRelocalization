%  Uses the network `net` to extract image representations from a list
%  of image filenames `imageFns`.
%  `imageFns` is a cell array containing image file names relative
%  to the `imPath` (i.e. `[imPath, imageFns{i}]` is a valid JPEG image).
%  The representations are saved to `outFn` (single 4-byte floats).
%
%  Additional options:
%
%  `useGPU': Use the GPU or not
%
%  `batchSize': The number of images to process in a batch. Note that if your
%       input images are not all of same size (they are in place recognition
%       datasets), you should set `batchSize` to 1.

function serialAllFeats_half_synth(net, imPath, imageFns, outFn, varargin)
    
    opts= struct(...
        'useGPU', true, ...
        'numThreads', 12, ...
        'batchSize', 10 ...
        );
    opts= vl_argparse(opts, varargin);
    simpleNnOpts= {'conserveMemory', true, 'mode', 'test'};
    
    relja_display('serialAllFeats: Start');
    
    if opts.useGPU
        net= relja_simplenn_move(net, 'gpu');
    else
        net= relja_simplenn_move(net, 'cpu');
    end
    
    nImages= length(imageFns);
    nBatches= ceil( nImages / opts.batchSize );
    
    numInBuffer= 0;
    
    prog= tic;
    
    for iBatch= 1:nBatches
      relja_progress(iBatch, nBatches, 'serialAllFeats', prog);
        
        iStart= (iBatch-1)*opts.batchSize +1;
        iEnd= min(iStart + opts.batchSize-1, nImages);
        
        thisImageFns= strcat( imPath, imageFns(iStart:iEnd) );
        thisNumIms= iEnd-iStart+1;
                
        ims_ = cell(1,thisNumIms);
        for ii=1:thisNumIms
          
%           load([thisImageFns{ii}(1:end-4) '.label.mat'],'label');
%           A = imread(thisImageFns{ii});
%           
%           mask = reshape(label==1,size(A,2),size(A,1))';
%           nmask = vl_imdown(single(mask))>0;
%           
%           A = double(vl_imdown(single(A)));
%           
%           im1 = A(:,:,1);
%           im2 = A(:,:,2);
%           im3 = A(:,:,3);
% 
%           im1(nmask(:)) = NaN;
%           im2(nmask(:)) = NaN;
%           im3(nmask(:)) = NaN;
% 
%           im1 = inpaint_nans(im1,2);
%           im2 = inpaint_nans(im2,2);
%           im3 = inpaint_nans(im3,2);
%           
%           ims_{ii} = single(cat(3,cat(3,im1,im2),im3));

% % %           fprintf('image preprocessing took %f\n',toc);
% %           
% % %           figure; imshow(uint8(ims_{ii}));          
% % %           keyboard;
% %           
% % %           load([thisImageFns{ii}(1:end-4) '.label.mat'],'label');
% % %           A = imread(thisImageFns{ii});
% % %            
% % %           tic
% % %           mask = reshape(label==1,size(A,2),size(A,1))';
% % %           nmask = vl_imdown(single(mask))>0;
% % %           mask = ~nmask;
% % %           
% % %           A = vl_imdown(single(A));
% % %           
% % %           im1 = A(:,:,1);
% % %           mean_v1 = mean(im1(mask(:)));
% % %           im2 = A(:,:,2);
% % %           mean_v2 = mean(im2(mask(:)));
% % %           im3 = A(:,:,3);
% % %           mean_v3 = mean(im3(mask(:)));
% % %           
% % %           im1(nmask(:)) = mean_v1;
% % %           im2(nmask(:)) = mean_v2;
% % %           im3(nmask(:)) = mean_v3;
% % %           
% % %           ims_{ii} = cat(3,cat(3,im1,im2),im3);
% % %           toc
          
        %% fill-in averageImage into black pixels           
          load([thisImageFns{ii}(1:end-4) '.label.mat'],'label');
          A = imread(thisImageFns{ii});
                              
          mask = reshape(label==1,size(A,2),size(A,1))';
          nmask = vl_imdown(single(~mask));
          mask = vl_imdown(single(mask));

          A = vl_imdown(single(A));
          A(:,:,1)= A(:,:,1) .* nmask + net.meta.normalization.averageImage(1,1,1)*mask;
          A(:,:,2)= A(:,:,2) .* nmask + net.meta.normalization.averageImage(1,1,2)*mask;
          A(:,:,3)= A(:,:,3) .* nmask + net.meta.normalization.averageImage(1,1,3)*mask;
          
          ims_{ii} = A; %vl_imdown(single(A));

        end      
        
%         ims_= vl_imreadjpeg(thisImageFns, 'numThreads', opts.numThreads);
        
        % fix non-colour images
        for iIm= 1:thisNumIms
            if size(ims_{iIm},3)==1
                ims_{iIm}= cat(3,ims_{iIm},ims_{iIm},ims_{iIm});
            end
        end
        ims= cat(4, ims_{:});
        
        ims(:,:,1,:)= ims(:,:,1,:) - net.meta.normalization.averageImage(1,1,1);
        ims(:,:,2,:)= ims(:,:,2,:) - net.meta.normalization.averageImage(1,1,2);
        ims(:,:,3,:)= ims(:,:,3,:) - net.meta.normalization.averageImage(1,1,3);
        
        if opts.useGPU
            ims= gpuArray(ims);
        end
        
        % ---------- extract features
        res= vl_simplenn(net, ims, [], [], simpleNnOpts{:});
        clear ims;
        feats= reshape( gather(res(end).x), [], thisNumIms );
        clear res;
        
        if iBatch==1
            fout= fopen(outFn, 'wb');
            [buffer, bufferSize]= relja_makeBuffer(feats(:,1), 200);
        end
        
        if (numInBuffer + thisNumIms > bufferSize)
            fwrite(fout, buffer(:, 1:numInBuffer), class(buffer));
            numInBuffer= 0;
        end
        buffer(:, numInBuffer+[1:thisNumIms])= feats;
        numInBuffer= numInBuffer+thisNumIms;
        
    end
    
    %%%%% flush buffer
    
    if numInBuffer>0
        fwrite(fout, buffer(:, 1:numInBuffer), class(buffer));
    end
    fclose(fout);
    
    
    relja_display('serialAllFeats: Done');
end
