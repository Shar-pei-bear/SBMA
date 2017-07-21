function [FlowFieldx,FlowFieldy] = Diamond_Search_Algorithm5(im_rgb_int8,im_rgb_int8_2,H,W,Window_size)
    [im_rgb] = im2double(im_rgb_int8);
    [im_rgb_2] = im2double(im_rgb_int8_2);
    [im_xyz] = rgb2xyz(im_rgb);
    [im_xyz_2] = rgb2xyz(im_rgb_2);
    cform = makecform('xyz2uvl');
    im_luv = applycform(im_xyz,cform);
    im_luv_2 = applycform(im_xyz_2,cform);
    im_l = im_luv(:,:,1);
    im_u = im_luv(:,:,2);
    im_v = im_luv(:,:,3);
    im_l_2 = im_luv_2(:,:,1);
    im_u_2 = im_luv_2(:,:,2);
    im_v_2 = im_luv_2(:,:,3);
    FlowFieldx = zeros(H,W);
    FlowFieldy = zeros(H,W);
    MBD = zeros(1,9);
    MBD_Lable = true(1,9);
    Window_Width = Window_size;
    Window_Height = Window_size;
    % Step 1) The initial LDSP is centered at the origin of the search window, and the 9 checking points of LDSP are tested. 
    % If the MBD point calculated is located at the center position,go to Step 3; otherwise, go to Step 2.
    for index_row = 1 : Window_Height : H 
        for index_column = 1 : Window_Width : W
            Component = false(H,W);
            Component(index_row:min((index_row+Window_Height-1),H),index_column:min((index_column+Window_Width-1),W)) = 1;
            MBD_Point = Component;
            im_l_Component = im_l(Component);
            im_u_Component = im_u(Component);
            im_v_Component = im_v(Component);
            Center_Point = false;
            MBD(1) = sum(abs(im_l_Component-im_l_2(MBD_Point)) + abs(im_u_Component-im_u_2(MBD_Point)) +abs(im_v_Component-im_v_2( MBD_Point)));
            while (~Center_Point)
                % the checking points outside the search window are truncated.
                if MBD_Lable(2)
                    Component_Neighbor(:,:,1) = circshift(MBD_Point,[2 0]);
                    MBD(2) = sum(abs(im_l_Component-im_l_2(Component_Neighbor(:,:,1))) + abs(im_u_Component-im_u_2(Component_Neighbor(:,:,1))) + abs(im_v_Component-im_v_2(Component_Neighbor(:,:,1))));
                end
                if MBD_Lable(3)
                    Component_Neighbor(:,:,2) = circshift(MBD_Point,[-2 0]);
                    MBD(3) = sum(abs(im_l_Component-im_l_2(Component_Neighbor(:,:,2))) + abs(im_u_Component-im_u_2(Component_Neighbor(:,:,2))) + abs(im_v_Component-im_v_2(Component_Neighbor(:,:,2))));
                end
                if MBD_Lable(4)
                    Component_Neighbor(:,:,3) = circshift(MBD_Point,[0 2]);
                    MBD(4) = sum(abs(im_l_Component-im_l_2(Component_Neighbor(:,:,3))) + abs(im_u_Component-im_u_2(Component_Neighbor(:,:,3))) + abs(im_v_Component-im_v_2(Component_Neighbor(:,:,3))));
                end
                if MBD_Lable(5)
                    Component_Neighbor(:,:,4) = circshift(MBD_Point,[0 -2]);
                    MBD(5) = sum(abs(im_l_Component-im_l_2(Component_Neighbor(:,:,4))) + abs(im_u_Component-im_u_2(Component_Neighbor(:,:,4))) + abs(im_v_Component-im_v_2(Component_Neighbor(:,:,4))));
                end
                if MBD_Lable(6)
                    Component_Neighbor(:,:,5) = circshift(MBD_Point,[1 1]);
                    MBD(6) = sum(abs(im_l_Component-im_l_2(Component_Neighbor(:,:,5))) + abs(im_u_Component-im_u_2(Component_Neighbor(:,:,5))) + abs(im_v_Component-im_v_2(Component_Neighbor(:,:,5))));
                end
                if MBD_Lable(7)
                    Component_Neighbor(:,:,6) = circshift(MBD_Point,[1 -1]);
                    MBD(7) = sum(abs(im_l_Component-im_l_2(Component_Neighbor(:,:,6))) + abs(im_u_Component-im_u_2(Component_Neighbor(:,:,6))) + abs(im_v_Component-im_v_2(Component_Neighbor(:,:,6))));
                end
                if MBD_Lable(8)
                    Component_Neighbor(:,:,7) = circshift(MBD_Point,[-1 -1]);
                    MBD(8) = sum(abs(im_l_Component-im_l_2(Component_Neighbor(:,:,7))) + abs(im_u_Component-im_u_2(Component_Neighbor(:,:,7))) + abs(im_v_Component-im_v_2(Component_Neighbor(:,:,7))));
                end
                if MBD_Lable(9)
                    Component_Neighbor(:,:,8) = circshift(MBD_Point,[-1 1]);
                    MBD(9) = sum(abs(im_l_Component-im_l_2(Component_Neighbor(:,:,8))) + abs(im_u_Component-im_u_2(Component_Neighbor(:,:,8))) + abs(im_v_Component-im_v_2(Component_Neighbor(:,:,8))));
                end
                if any(MBD_Point(:,1))
                     MBD([5,7,8]) = inf;
                end 
                if any(MBD_Point(:,2))
                     MBD(5) = inf;
                end       
                if any(MBD_Point(:,end))
                     MBD([4,6,9]) = inf;
                end
                if any(MBD_Point(:,end-1))
                     MBD(4) = inf;
                end
                if any(MBD_Point(1,:))
                     MBD([3,8,9]) = inf;
                end       
                if any(MBD_Point(2,:))
                     MBD(3) = inf;
                end            
                if any(MBD_Point(end,:))
                     MBD([2,6,7]) = inf;
                end
                if any(MBD_Point(end-1,:))
                     MBD(2) = inf;
                end
                [M,I] = min(MBD);
                % calculationg flow field
                MBD_Lable = true(1,9);
                switch I
                    case 1
                        Center_Point = true;
                    case 2
                        FlowFieldy(Component)= FlowFieldy(Component) - 2;
                        MBD_Lable(3,8,9) = 0;
                        MBD([3,8,9]) = MBD([1,7,6]);
                    case 3
                        FlowFieldy(Component)= FlowFieldy(Component) + 2;
                        MBD_Lable([2,6,7]) = 0;
                        MBD([2,6,7]) = MBD([1,9,8]);
                    case 4
                        FlowFieldx(Component)= FlowFieldx(Component) + 2;
                        MBD_Lable(5,7,8) = 0;
                        MBD([5,7,8]) = MBD([1,6,9]);		
                    case 5
                        FlowFieldx(Component)= FlowFieldx(Component) - 2;
                        MBD_Lable([4,6,9]) = 0;
                        MBD([4,6,9]) = MBD([1,7,8]);
                    case 6
                        FlowFieldx(Component)= FlowFieldx(Component) + 1;
                        FlowFieldy(Component)= FlowFieldy(Component) - 1;
                        MBD_Lable([3,5,7,8,9]) = 0;
                        MBD([3,5,7,8,9]) = MBD([9,7,2,1,4]);
                    case 7
                        FlowFieldx(Component)= FlowFieldx(Component) - 1;
                        FlowFieldy(Component)= FlowFieldy(Component) - 1;
                        MBD_Lable([3,4,6,8,9]) = 0;
                        MBD([3,4,6,8,9]) = MBD([8,6,2,5,1]);
                    case 8
                        FlowFieldx(Component)= FlowFieldx(Component) - 1;
                        FlowFieldy(Component)= FlowFieldy(Component) + 1;
                        MBD_Lable([2,4,6,7,9]) = 0;
                        MBD([2,4,6,7,9]) = MBD([7,9,1,5,3]);
                    case 9
                        FlowFieldx(Component)= FlowFieldx(Component) + 1;
                        FlowFieldy(Component)= FlowFieldy(Component) + 1;
                        MBD_Lable([2,5,6,7,8]) = 0;
                        MBD([2,5,6,7,8]) = MBD([6,8,4,1,3]);
                    otherwise
                end
                MBD(1) = MBD(I);
    %Step 2) The MBD point found in the previous search step is re-positioned as the center point to form a new LDSP.
    % If the new MBD point obtained is located at the center position, go to Step 3; otherwise, recursively repeat this step.
                if (~Center_Point) 
                    MBD_Point =   Component_Neighbor(:,:,I-1); 
                end
            end
    %Step 3) Switch the search pattern from LDSP to SDSP. The MBD point found in this step is the final solution of the motion vector which points to the best matching block.
            Component_Neighbor(:,:,1) = circshift(MBD_Point,[1 0]);
            MBD(2) = sum(abs(im_l_Component-im_l_2(Component_Neighbor(:,:,1))) + abs(im_u_Component-im_u_2(Component_Neighbor(:,:,1))) + abs(im_v_Component-im_v_2(Component_Neighbor(:,:,1))));
            Component_Neighbor(:,:,2) = circshift(MBD_Point,[-1 0]);
            MBD(3) = sum(abs(im_l_Component-im_l_2(Component_Neighbor(:,:,2))) + abs(im_u_Component-im_u_2(Component_Neighbor(:,:,2))) + abs(im_v_Component-im_v_2(Component_Neighbor(:,:,2))));
            Component_Neighbor(:,:,3) = circshift(MBD_Point,[0 1]);
            MBD(4) = sum(abs(im_l_Component-im_l_2(Component_Neighbor(:,:,3))) + abs(im_u_Component-im_u_2(Component_Neighbor(:,:,3))) + abs(im_v_Component-im_v_2(Component_Neighbor(:,:,3))));
            Component_Neighbor(:,:,4) = circshift(MBD_Point,[0 -1]);
            MBD(5) = sum(abs(im_l_Component-im_l_2(Component_Neighbor(:,:,4))) + abs(im_u_Component-im_u_2(Component_Neighbor(:,:,4))) + abs(im_v_Component-im_v_2(Component_Neighbor(:,:,4))));
    % the checking points outside the search window are truncated.
            if any(MBD_Point(:,1))
                MBD(5) = inf;
            end       
            if any(MBD_Point(:,end))
                MBD(4) = inf;
            end
            if any(MBD_Point(1,:))
                MBD(3) = inf;
            end
            if any(MBD_Point(end,:))
                MBD(2) = inf;
            end
            [M,I] = min(MBD(1:5)); 
            switch I
                case 2
                    FlowFieldy(Component)= FlowFieldy(Component) - 1;
                case 3
                    FlowFieldy(Component)= FlowFieldy(Component) + 1;
                case 4
                    FlowFieldx(Component)= FlowFieldx(Component) + 1;
                case 5
                    FlowFieldx(Component)= FlowFieldx(Component) - 1;
                otherwise
            end
        end
    end
end

