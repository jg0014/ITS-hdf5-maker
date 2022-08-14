# ITS-hdf5-maker

This code encode ITS_v2 dehazing dataset to a hdf5 file

# origional data set prepar

Down load ITS_v2/hazy, ITS_v2/trans and ITS/_v2/clear into ./ITS_v2

# usage

After prepared ITS_v2 dataset, run Make_5.m by matlab

# data augment

* resize each pair with random scale within range [0.6,1.0]
* random crop each pair
* random flip horizontally

# reference
* paper of ITS:B. Li et al., "Benchmarking Single-Image Dehazing and Beyond," in IEEE Transactions on Image Processing, vol. 28, no. 1, pp. 492-505, Jan. 2019, doi: 10.1109/TIP.2018.2867951.

# acknowledge
* Partially borrows from [MSBDN-DFF](https://github.com/BookerDeWitt/MSBDN-DFF/tree/master/HDF5)
