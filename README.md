## IDX

This is a parser for the [IDX file format](http://yann.lecun.com/exdb/mnist/). The MNIST data files are provided in the ``data`` folder. 

```julia
using IDX

load("data/train-images.idx3-ubyte")
```

The ``load`` function returns a triple: an array of dimensions, the datatype specified in the IDX file, and an array of the data.