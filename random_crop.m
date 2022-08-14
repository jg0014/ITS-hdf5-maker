function croped = random_crop(input,patch_size,rand_position,mirror)
%UNTITLED 此处显示有关此函数的摘要
%   rand_position:position of patch's up left corner
input_size = size(input);

assert(length(input_size)==3|length(input_size)==2,...
    'random_crop:input shape error, excepted length of input 2 or 3, get %d instead',length(input_size));

range_x = input_size(1) - patch_size(1);
range_y = input_size(2) - patch_size(2);

assert(rand_position(1)<range_x & rand_position(2)<range_y,'target_patch_bound_out_of_InputSize');


if length(input_size)==3
    patch = input(rand_position(1)+1:rand_position(1)+patch_size(1),rand_position(2)+1:rand_position(2)+patch_size(2),:);
end

if length(input_size)==2
    patch = input(rand_position(1)+1:rand_position(1)+patch_size(1),rand_position(2)+1:rand_position(2)+patch_size(2));
end

if mirror ==true
    croped = fliplr(patch);
else
    croped = patch;
end

end

