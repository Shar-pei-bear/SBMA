% define block size
clear all;
Window_size = 16;
image_index = 87;
frames_directory = '.\fish\frames\MVI_0057 0';
flows_directory = '.\fish\flows\MVI_0057 0';
[im_rgb_int8  ] = imread([frames_directory, num2str(image_index,'%03d'),'.jpg']);
[im_rgb_int8_2] = imread([frames_directory, num2str((image_index+1),'%03d'),'.jpg']);
load([flows_directory, num2str(image_index,'%03d'),'.mat']);
vy = -vy;% 定义的向上的方向不同,optical flow 和 ground truth 均如此
[H, W, dim] = size(im_rgb_int8);
[FlowFieldx,FlowFieldy] = Diamond_Search_Algorithm5(im_rgb_int8,im_rgb_int8_2,H,W,Window_size);
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