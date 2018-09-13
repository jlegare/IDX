module IDX

# The following description of the IDX format comes from
#
#    http://yann.lecun.com/exdb/mnist/
#
# which is also the source of the MNIST data. 
#
#    THE IDX FILE FORMAT
# 
#    The IDX file format is a simple format for vectors and multidimensional matrices of various numerical types.  The basic
#    format is
# 
#       magic number 
#       size in dimension 0 
#       size in dimension 1 
#       size in dimension 2 
#       ..... 
#       size in dimension N 
#       data
# 
#    The magic number is an integer (MSB first). The first 2 bytes are always 0.
# 
#    The third byte codes the type of the data: 
# 
#       0x08: unsigned byte 
#       0x09: signed byte 
#       0x0B: short (2 bytes) 
#       0x0C: int (4 bytes) 
#       0x0D: float (4 bytes) 
#       0x0E: double (8 bytes)
# 
#    The 4-th byte codes the number of dimensions of the vector/matrix: 1 for vectors, 2 for matrices....
# 
#    The sizes in each dimension are 4-byte integers (MSB first, high endian, like in most non-Intel processors).

# ----------------------------------------
# EXPORTED INTERFACE
# ----------------------------------------

export load

# ----------------------------------------
# CONSTANTS
# ----------------------------------------

const type_constructors = [ UInt8,
                            Int8,
                            Int16, # Actually, this one is unused. I'm really not sure why ... I haven't found proper
                                   # documentation for the format other than the website reference quoted above.
                            Int16, 
                            Int32,
                            Float32,
                            Float64 ]
                
# ----------------------------------------
# FUNCTIONS
# ----------------------------------------

function items(handle, constructor, sizes)
    return ( sizes, constructor, convert(Array{constructor}, read(handle, prod(sizes) * sizeof(constructor))) )
end


function load(file_name)
    handle = open(file_name, "r")

    ( _, _, constructor, dimension ) = magic_number(handle)

    return items(handle, constructor, sizes(handle, dimension))
end


function magic_number(handle; constructor = nothing)
    magic_number = bswap(read(handle, UInt32))

    ( _, _, type_index, dimension ) = ( UInt8(magic_number & 0xFF000000 >> 0x18),
                                        UInt8(magic_number & 0x00FF0000 >> 0x10),
                                        UInt8(magic_number & 0x0000FF00 >> 0x08),
                                        UInt8(magic_number & 0x000000FF >> 0x00) )

    if type_index < 0x01 || type_index > 0x07 || type_index == 0x04
        throw(DomainError(type_index, "Invalid magic number ... the type index \"$type_index\" is out of range."))
    end

    return ( 0x00, 0x00, constructor == nothing ? type_constructors[type_index] : constructor, dimension )
end


function sizes(handle, dimension)
    return map(_::Int64 -> bswap(read(handle, UInt32)), 1:dimension)
end

end
