close all;

img = rgb2gray(imread('eg1.png'));

[f1,d1] = vl_sift(single(img),'verbose');

[f,desc] = vl_covdet(single(img),'Method','DoG',...
  'EstimateOrientation', true, ...
'descriptor','SIFT','OctaveResolution', 4, 'DoubleImage', false,'verbose');

f(:,3:6) = -f(:,3:6);
[f,desc] = vl_covdet(single(img),'Frames',f,...
'descriptor','SIFT','OctaveResolution', 4, 'DoubleImage', false,'verbose');


f1(:,1:10)
f(:,1:10)


ii=1;
jj=1;
figure; hold on; 
plot(desc(:,ii),'b'); 
plot(single(d1(:,jj))./norm(single(d1(:,jj))),'r'); 
legend('covdet','sift');