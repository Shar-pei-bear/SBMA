flow = zeros(32,32,2);
vy = (15.5:-1:-15.5)*1;
vy = vy';
vx = (-15.5:1:15.5)*1;
flow(:,:,1) = ones(32,1)*vx;
flow(:,:,2) = vy*ones(1,32);
imflow = flowToColor(flow);
H = 32;
W = 32;
[x,y] = meshgrid(1:1:W,H:-1:1);
figure, imshow(imflow);
figure, flow_field = quiver(x,y,flow(:,:,1),flow(:,:,2));
axis([0 32 0 32]);
axis equal
imwrite(imflow,'Color_flowfield.jpg');