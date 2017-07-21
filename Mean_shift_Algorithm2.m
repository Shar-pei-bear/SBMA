function [Features,New_Color_Num] = Mean_shift_Algorithm2( im_rgb,im_l,im_u,im_v,H,W,dim,r,N_min,N_con)
im_rgb_mean = (im_rgb + circshift(im_rgb,[0  1]) + circshift(im_rgb,[0  -1]) + circshift(im_rgb,[ 1 0]) + ...
                        circshift(im_rgb,[1  1]) + circshift(im_rgb,[1  -1]) + circshift(im_rgb,[-1 1]) + ...
                        circshift(im_rgb,[-1 0]) + circshift(im_rgb,[-1 -1]))/9;
im_xyz_mean = rgb2xyz(im_rgb_mean);
cform = makecform('xyz2uvl');
im_luv_mean = applycform(im_xyz_mean,cform);
im_l_mean = im_luv_mean(:,:,1);
im_u_mean = im_luv_mean(:,:,2);
im_v_mean = im_luv_mean(:,:,3);

% Definition of the segmentation parameters
covmatrix1 = cov(im_l,im_l);
sigma1 = trace(covmatrix1);
covmatrix2 = cov(im_u,im_u);
sigma2 = trace(covmatrix2);
covmatrix3 = cov(im_v,im_v);
sigma3 = trace(covmatrix3);
r = r*sqrt(sigma1+sigma2+sigma3);
im_luv_square = im_l.^2 + im_u.^2 + im_v.^2;%part of the distance calculation
Palette = zeros(floor(H*W/N_min),dim);
Final_Palette = zeros(floor(H*W/N_min),dim);
img_overall = zeros(H,W);
Neighbors =  false(H,W,1);
Features  =  false(H,W,1);
Color_Num = 1;
Remained_Features = true(H,W);
Feature_candidates = Remained_Features;
Feature_candidates(1,:)=0;
Feature_candidates(:,1)=0;
Feature_candidates(end,:)=0;
Feature_candidates(:,end)=0;
Remained_pixels = true(H,W);
img_segemented_luv = zeros(H,W,dim);
pixel_candidates = zeros(25,1);
Component_Neighbor = true(H,W,8);
img_edge = false(H,W);
%5. [ID+FS] Iterations.
% Definition of the search window
while (1)
    Feature_candidates(2:end-1,2:end-1) = Remained_Features(2:end-1,2:end-1);
    Remained_img = [im_l_mean(Feature_candidates),im_u_mean(Feature_candidates),im_v_mean(Feature_candidates)];
    if (size(Remained_img,1) == 0)
        break;
    end
    Window_candidates = randi(size(Remained_img,1),[25,1]);
    for M =1:25
        pixel_mean_luv = Remained_img(Window_candidates(M),:);
        pixel_distance = im_luv_square(Remained_Features) -r^2 + sum(pixel_mean_luv.^2)-2*pixel_mean_luv(1)*im_l(Remained_Features)-2*pixel_mean_luv(2)*im_u(Remained_Features)-2*pixel_mean_luv(3)*im_v(Remained_Features);
        pixel_candidates(M,1) =length(find(pixel_distance<0));
    end
    [HighDensity,I] = max(pixel_candidates);
    if HighDensity < N_min
        break;
    end
    Window = Remained_img(Window_candidates(I),:);
    Window = squeeze(Window);
    %3. [FS] Mean shift algorithm.
    Shift_Amplitude = 1;
    Feature_shift = 0;
    iteration = 0;
    while Shift_Amplitude > 0.01 && iteration < 1000
        iteration = iteration +1;
        Window = Window + Feature_shift;
        Feature_distance = im_luv_square -r^2 + sum(Window.^2)-2*Window(1)*im_l-2*Window(2)*im_u-2*Window(3)*im_v;
        Detected_Feature = ((Feature_distance<0)&Remained_Features);
        Feature_mean = [mean(im_l(Detected_Feature)),mean(im_u(Detected_Feature)),mean(im_v(Detected_Feature))];
        Feature_shift = Feature_mean - Window;
        Shift_Amplitude = sum(Feature_shift.^2);
    end
    %[ID+FS] Removal of the detected feature.
    Component_Neighbor(:,:,1) = circshift(Detected_Feature,[1  0]);
    Component_Neighbor(1,:,1) = 0;
    Component_Neighbor(:,:,2) = circshift(Detected_Feature,[-1 0]);
    Component_Neighbor(end,:,2) =0;
    Component_Neighbor(:,:,3) = circshift(Detected_Feature,[0  1]);
    Component_Neighbor(:,1,3) = 0;
    Component_Neighbor(:,:,4) = circshift(Detected_Feature,[0 -1]);
    Component_Neighbor(:,end,4) = 0;
    Component_Neighbor(:,:,5) = circshift(Detected_Feature,[1 1]);
    Component_Neighbor(1,:,5) = 0;
    Component_Neighbor(:,1,5) = 0;
    Component_Neighbor(:,:,6) = circshift(Detected_Feature,[1 -1]);
    Component_Neighbor(1,:,6) = 0;
    Component_Neighbor(:,end,6) = 0;
    Component_Neighbor(:,:,7) = circshift(Detected_Feature,[-1 -1]);
    Component_Neighbor(end,:,7) = 0;
    Component_Neighbor(:,end,7) = 0;
    Component_Neighbor(:,:,8) = circshift(Detected_Feature,[-1 1]);
    Component_Neighbor(end,:,8) = 0;
    Component_Neighbor(:,1,8) =0 ;
    Component_Neighbors = (Detected_Feature | Component_Neighbor(:,:,1) | Component_Neighbor(:,:,2) | Component_Neighbor(:,:,3) | Component_Neighbor(:,:,4) | ...
        Component_Neighbor(:,:,5) | Component_Neighbor(:,:,6) | Component_Neighbor(:,:,7) | Component_Neighbor(:,:,8)) & Remained_Features;
    Remained_Features = xor(Remained_Features,Component_Neighbors);
    % 6. [ID] Determining the initial feature palette.
    imLabel = bwlabel(Component_Neighbors,8);
    stats = regionprops(imLabel,'Area');
    allArea = [stats.Area];
    max_area = max(allArea(:));
    if (max_area > N_min)
        Palette(Color_Num,:) =  Window;
        Remained_pixels = xor(Remained_pixels,Detected_Feature);
        Features (:,:,Color_Num) = Detected_Feature;
        Neighbors(:,:,Color_Num) = Component_Neighbors;
        Color_Num = Color_Num + 1;
    end
end
% 7. [ID+FS] Determining the final feature palette.
New_Color_Num = Color_Num;
Color_Num = Color_Num-1;
r = r*(2^(1/3));
for Palette_Num = 1: Color_Num
    Window =  Palette(Palette_Num,:);
    Feature_distance = im_luv_square -r^2 + sum(Window.^2)-2*Window(1)*im_l-2*Window(2)*im_u-2*Window(3)*im_v;
    Detected_Feature = ((Feature_distance<0) & Remained_pixels & Neighbors(:,:,Palette_Num));
    if (any(Detected_Feature(:)))
        Features (:,:,Palette_Num) = Features (:,:,Palette_Num) | Detected_Feature;
        Remained_pixels = xor(Remained_pixels,Detected_Feature);
        Final_Palette(Palette_Num,:) = [mean(im_l(Features (:,:,Palette_Num))),mean(im_u(Features (:,:,Palette_Num))),mean(im_v(Features (:,:,Palette_Num)))];
        Palette(New_Color_Num,:) = Final_Palette(Palette_Num,:);
        New_Color_Num = New_Color_Num + 1;
    else
        Final_Palette(Palette_Num,:) = Palette(Palette_Num,:);
    end
end
%These pixels are allocated to the closest color in the final feature palette.
Closest_Feature = zeros(H,W);
temp = 1./zeros(H,W);
for Palette_Num = 1: Color_Num
    Window =  Final_Palette(Palette_Num,:);
    Feature_distance = sum(Window.^2)-2*Window(1)*im_l-2*Window(2)*im_u-2*Window(3)*im_v;
    Closest_Feature(temp > Feature_distance) = Palette_Num;
    temp(temp > Feature_distance) = Feature_distance (temp > Feature_distance);
end
New_Color_Num = Color_Num + 1;
for Palette_Num = 1: Color_Num
    Fill_img = (Closest_Feature == Palette_Num) &  Remained_pixels;
    if all(Palette(Palette_Num,:) == Final_Palette(Palette_Num,:))
        Features (:,:,Palette_Num) = Features (:,:,Palette_Num) | Fill_img;
    else
        Features (:,:,New_Color_Num) = Fill_img;
        New_Color_Num = New_Color_Num + 1;
    end
end
%8. [ID+FS] Postprocessing
New_Color_Num = New_Color_Num -1 ;
for Palette_Num = 1: New_Color_Num
    img_overall = img_overall + Palette_Num *  Features (:,:,Palette_Num);
end
for Palette_Num = 1: New_Color_Num
    Connected_Comp = Features (:,:,Palette_Num);
    imLabel = bwlabel(Connected_Comp,8);                %对各连通域进行标记
    stats = regionprops(imLabel,'Area');    %求各连通域的大小
    allArea = [stats.Area];
    index = find(allArea < N_con);             %求连通域大小大于阈值的索引
    Features (:,:,Palette_Num) = xor(Features (:,:,Palette_Num),ismember(imLabel,index(:)));
    for Compnent_Num = index
        Small_Component = (imLabel == Compnent_Num);
        Component_Neighbor(:,:,1) = circshift(Small_Component,[1  0]);
        Component_Neighbor(1,:,1) = 0;
        Component_Neighbor(:,:,2) = circshift(Small_Component,[-1 0]);
        Component_Neighbor(end,:,2) =0;
        Component_Neighbor(:,:,3) = circshift(Small_Component,[0  1]);
        Component_Neighbor(:,1,3) = 0;
        Component_Neighbor(:,:,4) = circshift(Small_Component,[0 -1]);
        Component_Neighbor(:,end,4) = 0;
        Component_Neighbor(:,:,5) = circshift(Small_Component,[1 1]);
        Component_Neighbor(1,:,5) = 0;
        Component_Neighbor(:,1,5) = 0;
        Component_Neighbor(:,:,6) = circshift(Small_Component,[1 -1]);
        Component_Neighbor(1,:,6) = 0;
        Component_Neighbor(:,end,6) = 0;
        Component_Neighbor(:,:,7) = circshift(Small_Component,[-1 -1]);
        Component_Neighbor(end,:,7) = 0;
        Component_Neighbor(:,end,7) = 0;
        Component_Neighbor(:,:,8) = circshift(Small_Component,[-1 1]);
        Component_Neighbor(end,:,8) = 0;
        Component_Neighbor(:,1,8) =0 ;
        Component_Neighbors = (Component_Neighbor(:,:,1) | Component_Neighbor(:,:,2) | Component_Neighbor(:,:,3) | Component_Neighbor(:,:,4) | ...
                               Component_Neighbor(:,:,5) | Component_Neighbor(:,:,6) | Component_Neighbor(:,:,7) | Component_Neighbor(:,:,8)) & (~Small_Component);
        Neighbor_Feature = mode(img_overall(Component_Neighbors));
        Features (:,:,Neighbor_Feature) = Features (:,:,Neighbor_Feature) | Small_Component;
        img_overall(Small_Component) = Neighbor_Feature;
    end
end
for Palette_Num = 1: New_Color_Num
    Window =  Palette(Palette_Num,:);
    img_edge = img_edge | bwperim(Features (:,:,Palette_Num),8);
    img_segemented_luv(:,:,1) = img_segemented_luv(:,:,1) + Window(1)*Features (:,:,Palette_Num);
    img_segemented_luv(:,:,2) = img_segemented_luv(:,:,2) + Window(2)*Features (:,:,Palette_Num);
    img_segemented_luv(:,:,3) = img_segemented_luv(:,:,3) + Window(3)*Features (:,:,Palette_Num);
end
figure, imshow(img_edge);
imwrite(img_edge,'segmented_image_edge.jpg');
cform = makecform('uvl2xyz');
img_segemented_xyz = applycform(img_segemented_luv,cform);
img_segemented_rgb = xyz2rgb(img_segemented_xyz);
figure, imshow(img_segemented_rgb);
imwrite(img_segemented_rgb,'segmented_image.jpg');
end

