load .\noise\Error\SBMAError.mat SBMAError;
load .\noise\Error\BMAError.mat BMAError;
load .\noise\Error\Iterative_LK_Error.mat Iterative_LK_Error;
index = 1:size(Iterative_LK_Error,2);
index = index/100;
plot(index,SBMAError,'x-',index,BMAError,'s-',index,Iterative_LK_Error,'d-')
set(gca,'fontsize',20);