// types.zig - classifying and analyzing input data

const std = @import("std");
const deque = @import("deque.zig");

/// The Bytes deque is a Deque<u8> type used for general processing
/// of bytestreams. Used mostly for reading inputs from files/streams.
pub const Bytes = deque.init(u8, std.heap.page_allocator);

/// The DataType enum describes the type of data we are parsing and
/// storing in memory. Basic types like nil/int/float/bool are small,
/// other types will require larger structs or pointers to fully encapsulate.
/// Lists are effectively linked lists, and may use the deque structure.
/// Strings are roughly the same, but should be treated as fully immutable.
pub const DataType = enum(u8) {
    Nil, // nothing type
    Integer, // only 64 bits
    Float, // only 64 bits
    LongInt, // doesn't fit in 64-bit space
    LongFloat, // same as above
    Complex, // f64 * f64 complex type
    Symbol, // alphanumeric with a ' quote ('a, 'cow, etc)
    Identifier, // not quoted reference to some identifier
    String, // contiguous block of text in memory
    List, // list of elements
};


// end rawtypes.zig
