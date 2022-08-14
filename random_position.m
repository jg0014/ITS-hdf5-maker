function [x,y] = random_position(org_size,patch_size,numb)
%UNTITLED 此处显示有关此函数的摘要
%   org_size: origional image size(X,Y)
%   patch_size: target patch size(x,y)
%   numb :patch number of genereating
range_x = org_size(1) - patch_size(1);
range_y = org_size(2) - patch_size(2);

random_x = rand(numb,1);
random_y = rand(numb,1);

x = floor(random_x*range_x);
y = floor(random_y*range_y);
end

