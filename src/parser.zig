// parser.zig - a small parser state machine

const std = @import("std");

const types = @import("types.zig");
pub const DataType = types.DataType;
pub const Bytes = types.Bytes;


/// Implement a tiny state machine to detect the input bytes
/// and classify what the data stream is supposed to be.
/// Differentiates between numerals, symbols, positive/negative values, etc
const ParserInfo = struct {
    const Self = @This();

    numeric_only: bool,
    dot_detected: bool,
    is_quoted: bool,
    plus_minus_found: bool,
    i_or_j_last: bool,

    fn init() Self {
        return .{
            .numeric_only = true,
            .dot_detected = false,
            .is_quoted = false,
            .plus_minus_found = false,
            .i_or_j_last = false,
        };
    }
};

/// General parser error class.
const ParseErr = error{
    InvalidSyntax,
    TokenizeError,
};

/// Determine if a character code is numeric or not
/// 48 == '0'
/// 57 == '9'
/// the '.' is not included in this (parser-level check)
/// same for 'j' for complex
pub fn is_numeric(char: u8) bool {
    return switch (char) {
        48...57 => true,
        else => false,
    };
}

/// Determine if a character code is alphabetical
/// 65 == 'a', 90 == 'z'
/// 97 == 'A', 122 = 'Z'
pub fn is_alpha(char: u8) bool {
    return switch (char) {
        65...90 => true,
        97...122 => true,
        else => false,
    };
}

/// Determine the Lisp-type of a sequence of data
/// Should be used on a complete token, no spaces
pub fn parse(data: *Bytes) ParseErr!DataType {
    var ptr = data.head;
    var parse_info = ParserInfo.init();
    var counter: usize = 0;
    var curr_v: u8 = 0;

    while (ptr != null) : (ptr = ptr.?.*.next) {
        curr_v = ptr.?.*.value;

        if ((curr_v == '\'') and (counter == 0)) {
            parse_info.is_quoted = true;
        } else {
            // only run these if the input is still a numeric type
            if (parse_info.numeric_only) {
                switch (curr_v) {
                    '.' => {
                        if (!parse_info.dot_detected) {
                            parse_info.dot_detected = true;
                        } else {
                            parse_info.numeric_only = false;
                        }
                    },
                    '-' => {
                        if (!parse_info.plus_minus_found) {
                            parse_info.plus_minus_found = true;
                        } else {
                            parse_info.numeric_only = false;
                        }
                    },
                    '+' => {
                        if (!parse_info.plus_minus_found) {
                            parse_info.plus_minus_found = true;
                        } else {
                            parse_info.numeric_only = false;
                        }
                    },
                    'i' => {
                        if (ptr.?.*.next == null) {
                            parse_info.i_or_j_last = true;
                        } else {
                            parse_info.numeric_only = false;
                        }
                    },
                    'j' => {
                        if (ptr.?.*.next == null) {
                            parse_info.i_or_j_last = true;
                        } else {
                            parse_info.numeric_only = false;
                        }
                    },
                    // ansi values for 0 through 9
                    48...57 => {},
                    else => { parse_info.numeric_only = false; },
                }
            }
        }

        // bump counter
        counter += 1;
    }

    // toggle this on for additional help
    //std.debug.print("Parse info: {any}\n", .{parse_info});

    // determine the final outcome
    if (counter == 0) {
        return DataType.Nil;
    }

    if (parse_info.is_quoted) {
        return DataType.Symbol;
    }

    if ((parse_info.numeric_only) and (parse_info.dot_detected)) {
        return DataType.Float;
    }

    if (parse_info.numeric_only) {
        if (parse_info.i_or_j_last)
            return DataType.Complex;
        return DataType.Integer;
    }

    if (counter > 0) {
        return DataType.Identifier;
    }

    return ParseErr.InvalidSyntax;
}

// end parser.zig
