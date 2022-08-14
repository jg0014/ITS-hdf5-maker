function [curr_hazy_sz,  curr_trans_sz, curr_clear_sz] = store2h5(filename, hazy, trans, clear, create, startloc, chunksz)
 % *hazy* is W*H*C*N matrix of hazy images should be normalized (e.g. to lie between 0 and 1) beforehand
 % *trans* is W*H*N matrix of transmission map
  % *clear* is D*N matrix of clear image (D labels per sample) 
  % *create* [0/1] specifies whether to create file newly or to append to previously created file, useful to store information in batches when a dataset is too big to be held in memory  (default: 1)
  % *startloc* (point at which to start writing data). By default, 
  % if create=1 (create mode), startloc.data=[1 1 1 1], and startloc.lab=[1 1]; 
  % if create=0 (append mode), startloc.data=[1 1 1 K+1], and startloc.lab = [1 K+1]; where K is the current number of samples stored in the HDF
  % chunksz (used only in create mode), specifies number of samples to be stored per chunk (see HDF5 documentation on chunking) for creating HDF5 files with unbounded maximum size - TLDR; higher chunk sizes allow faster read-write operations 

  % verify that format is right
  hazy_dims=size(hazy);          %%data* is W*H*C*N
  trans_dims=size(trans);
  clear_dims=size(clear);
  num_samples=hazy_dims(end); %dat_dims���һά����N

 
  
  if ~exist('create','var')  %������ʱ�贴��
    create=true;
  end
  
  if create      %����ģʽ
    %fprintf('Creating dataset with %d samples\n', num_samples);
    if ~exist('chunksz', 'var')
      chunksz=1000;
    end
    if exist(filename, 'file')
      fprintf('Warning: replacing existing file %s \n', filename);
      delete(filename);
    end     
    
    %����ѹ�����ݼ���filenameΪHDF5�ļ�����/dataΪҪ����HDF5�ļ������ݼ����ƣ�
    %[dat_dims(1:end-1)Inf]���ݼ���С��'Datatype', 'single'�������͵�����
    %'ChunkSize', [dat_dims(1:end-1) chunksz])�ֿ��С
    h5create(filename, '/hazy', [hazy_dims(1:end-1) Inf], 'Datatype', 'single', 'ChunkSize', [hazy_dims(1:end-1) chunksz]); % width, height, channels, number
    h5create(filename, '/trans', [trans_dims(1:end-1) Inf], 'Datatype', 'single', 'ChunkSize', [trans_dims(1:end-1) chunksz]); % width, height, channels, number
    h5create(filename, '/clear', [clear_dims(1:end-1) Inf], 'Datatype', 'single', 'ChunkSize', [clear_dims(1:end-1) chunksz]); % width, height, channels, number 
    
    if ~exist('startloc','var')   %������ʱ��ʼ��Ϊȫ1����
      startloc.hazy=[ones(1,length(hazy_dims)-1), 1];  %����length(dat_dims)-1άȫ1����Ȼ����������1
      startloc.trans=[ones(1,length(trans_dims)-1), 1];
      startloc.clear=[ones(1,length(clear_dims)-1), 1];
    end 
  else  % append mode׷��ģʽ
    if ~exist('startloc','var')
      info=h5info(filename);   %�����й� filename ָ�������� HDF5 �ļ�����Ϣ
      prev_hazy_sz=info.Datasets(1).Dataspace.Size;
      prev_trans_sz=info.Datasets(2).Dataspace.Size;
      prev_clear_sz=info.Datasets(3).Dataspace.Size;
      
      assert(prev_hazy_sz(1:end-1)==hazy_dims(1:end-1), 'hazy dimensions must match existing dimensions in dataset'); %������ά�Ⱥ��Ѵ��ڵ�������ͬ��
      assert(prev_trans_sz(1:end-1)==trans_dims(1:end-1),'trans dimensions must match existing dimensions in dataset')
      assert(prev_clear_sz(1:end-1)==clear_dims(1:end-1), 'clear dimensions must match existing dimensions in dataset');
      startloc.hazy=[ones(1,length(hazy_dims)-1), prev_hazy_sz(end)+1];  %����֮ǰ�����ݺ��棬��ԭ���ݺ�һ����ʼ��ȫ1����
      startloc.trans=[ones(1,length(trans_dims)-1), prev_trans_sz(end)+1];
      startloc.clear=[ones(1,length(clear_dims)-1), prev_clear_sz(end)+1];
    end
  end

  if ~isempty(hazy)
    h5write(filename, '/hazy', single(hazy), startloc.hazy, size(hazy));%������д��HDF5���ݼ�����startloc.datΪ��ʼд�������λ��
    h5write(filename, '/trans', single(trans), startloc.trans, size(trans));
    h5write(filename, '/clear', single(clear), startloc.clear, size(clear));  
  end

  if nargout   %nargout���غ����������������
    info=h5info(filename);      %�����й� filename ָ�������� HDF5 �ļ�����Ϣ
    curr_hazy_sz=info.Datasets(1).Dataspace.Size;
    curr_trans_sz=info.Datasets(2).Dataspace.Size;
    curr_clear_sz=info.Datasets(3).Dataspace.Size;
  end
end

