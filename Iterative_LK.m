clear all;
% set optical flow parameters (see Coarse2FineTwoFrames.m for the definition of the parameters)
alpha = 0.012;
ratio = 0.75;
minWidth = 20;
nOuterFPIterations = 7;
nInnerFPIterations = 1;
nSORIterations = 30;
para = [alpha,ratio,minWidth,nOuterFPIterations,nInnerFPIterations,nSORIterations];

frames_directory = '.\fish\frames\MVI_0057 0';
flows_directory = '.\fish\flows\MVI_0057 0';
image_index = 87;
im1 = im2double(imread([frames_directory, num2str(image_index,'%03d'),'.jpg']));
im2 = im2double(imread([frames_directory, num2str((image_index+1),'%03d'),'.jpg']));
[H,W,dim] = size(im1);
load([flows_directory, num2str(image_index,'%03d'),'.mat']);
vy = -vy;% 定义的向上的方向不同,optical flow 和 ground truth 均如此
% this is the core part of calling the mexed dll file for computing optical flow
[FlowFieldx,FlowFieldy,warpI2] = Coarse2FineTwoFrames(im1,im2,para);
FlowFieldy = -FlowFieldy;

FlowField(:,:,1) = FlowFieldx;
FlowField(:,:,2) = FlowFieldy;
imflow = flowToColor(FlowField);
figure, imshow(imflow);
imwrite(imflow,'Flow_Field.jpg');

ErrorFlowField(:,:,1) = vx - FlowField(:,:,1);
ErrorFlowField(:,:,2) = vy - FlowField(:,:,2);
imflow = flowToColor(ErrorFlowField);
figure, imshow(imflow);
imwrite(imflow,'Error_Flow_Field.jpg');