%% These are original data path and h5 file save path
% HR_patch LR_patch LR_Blur_patch
clear ;
close all;
folder ='ITS_v2';
%folder = '/4TB/datasets/RESIDE/test';
save_root ='h5bymat/ITS_h5.h5';

%% scale factors: some opitions for argumentation
scale = 4;
down_scale_num = 3;
random_crop_num= 3;
patch_size = 256;

%% generate data: ergodic datas and argumentation
clear_path = fullfile(folder, 'clear');
trans_path = fullfile(folder, 'trans');
hazy_path = fullfile(folder, 'hazy');

hazy_image_files = dir(fullfile(hazy_path, '*.png'));

totalct = 0;
created_flag = false;
for n = 1:length(hazy_image_files)
    
    hazy = zeros(patch_size, patch_size, 3, 1);
    trans = zeros(patch_size,patch_size,1);
    clear = zeros(patch_size, patch_size, 3, 1); %set the data size
    count = 0;
    
    split_hazy = strsplit(hazy_image_files(n).name,'_');
    
    trans_file = fullfile(trans_path,strcat(split_hazy(1),'_',split_hazy(2),'.png'));
    clear_file = fullfile(clear_path,strcat(split_hazy(1),'.png'));
    
    hazy_image = imread(fullfile(hazy_path,hazy_image_files(n).name));
    trans_maps = imread(trans_file{1});
    clear_image= imread(clear_file{1});
    
    %generate random down parameter
    random_dowm = rand(down_scale_num,1);
    downsizes= random_dowm*0.4+0.6;
    
    for i = 1:down_scale_num
        hazy_scaled = imresize(hazy_image,downsizes(i),'bicubic');
        trans_scaled = imresize(trans_maps,downsizes(i),'bicubic');
        clear_scaled = imresize(clear_image,downsizes(i),'bicubic');
        
        hazy_scaled = im2double(hazy_scaled);
        trans_scaled = im2double(trans_scaled);
        clear_scaled = im2double(clear_scaled);
        
        im_size = size(trans_scaled);
        [x_list,y_list] =random_position(im_size,[patch_size patch_size],random_crop_num);
        
        for j = 1:random_crop_num
            x = x_list(1); y = y_list(2);
            mirror = false;
            mirror_factor = rand(1,1);
            if mirror_factor <0.5
                mirror = true;
            end
            
            hazy_croped = random_crop(hazy_scaled,[patch_size patch_size], [x y],mirror);
            trans_croped= random_crop(trans_scaled,[patch_size patch_size], [x y],mirror);
            clear_croped= random_crop(clear_scaled,[patch_size patch_size], [x y],mirror);
            
            %figure; imshow(hazy_croped);
            %figure; imshow(trans_croped);
            %figure; imshow(clear_croped);
            
            count=count+1;
            hazy(:,:,:,count)= hazy_croped;
            trans(:,:,count)= trans_croped;
            clear(:,:,:,count)= clear_croped;
        end 
    end
    order = randperm(count); %disorder
    hazy = hazy(:, :, :, order);
    trans = trans(:, :, order);
    clear = clear(:, :, :, order);
    
    %% writing to h5 file
    chunksz = down_scale_num*random_crop_num;
    
    last_read = (n-1)*chunksz;
    startloc = struct( 'hazy',[1,1,1,totalct+1],'trans',[1,1,totalct+1],  'clear', [1,1,1,totalct+1]);
    curr_hazy_sz = store2h5(save_root, hazy, trans, clear, ~created_flag, startloc, chunksz); 
    created_flag = true;
    totalct = curr_hazy_sz(end);
    
    disp(hazy_image_files(n).name)
    disp(totalct)
end
h5disp(save_root);

