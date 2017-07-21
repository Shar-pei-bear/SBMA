clear all;
r = 0.2;% parameter definition
N_min = 50;
N_con = 10;
frames_directory = '.\fish\frames\MVI_0057 0';
flows_directory = '.\fish\flows\MVI_0057 0';
image_index = 87;
[im_rgb_int8  ] = imread([frames_directory, num2str(image_index,'%03d'),'.jpg']);
[im_rgb_int8_2] = imread([frames_directory, num2str((image_index+1),'%03d'),'.jpg']);
load([flows_directory, num2str(image_index,'%03d'),'.mat']);
vy = -vy;% 定义的向上的方向不同,optical flow 和 ground truth 均如此
[im_rgb]   = im2double(im_rgb_int8  );
[im_rgb_2] = im2double(im_rgb_int8_2);
[im_xyz  ] = rgb2xyz(im_rgb  );
[im_xyz_2] = rgb2xyz(im_rgb_2);
cform = makecform('xyz2uvl');
im_luv      = applycform(im_xyz     ,cform);
im_luv_2    = applycform(im_xyz_2   ,cform);
im_l   = im_luv(:,:,1);
im_u   = im_luv(:,:,2);
im_v   = im_luv(:,:,3);
im_l_2 = im_luv_2(:,:,1);
im_u_2 = im_luv_2(:,:,2);
im_v_2 = im_luv_2(:,:,3);
[H, W, dim] = size(im_luv);
FlowField = zeros(H,W,2);
[Features,New_Color_Num] = Mean_shift_Algorithm2( im_rgb,im_l,im_u,im_v,H,W,dim,r,N_min,N_con);
[FlowFieldx,FlowFieldy] = Diamond_Search_Algorithm4(Features,New_Color_Num,im_l,im_u,im_v,im_l_2,im_u_2,im_v_2,H,W);

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