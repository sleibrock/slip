const std = @import("std");

const deq = @import("deque.zig");
const parser = @import("parser.zig");

fn printchar(c: u8) void {
    _ = std.debug.print("{c}", .{c});
}

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();
    const stdin_file = std.io.getStdIn().reader();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    var char: u8 = 0;
    var input = parser.Bytes.init();

    try stdout.print("Welcome to slip!\n", .{});
    try bw.flush();

    while (true) {
        char = 0;
        try stdout.print("> ", .{});
        try bw.flush();

        while (char != '\n') {
            // while we read a valid non-newline non-zero character, append 
            if (char != 0) {
                try input.append(char);
            }

            char = stdin_file.readByte() catch |err| {
                switch (err) {
                    else => {
                        // handle generic error with a goodbye message
                        std.debug.print("\nGoodbye!\n", .{});
                        return;
                    },
                }
            };
        }
        input.foreach(printchar);

        // try to parse it using the parser
        const result = try parser.parse(&input);

        input.clear();
        try stdout.print("\nResult: {any}\n", .{result});

        try bw.flush();
    }
    std.debug.print("\nGoodbye!\n", .{});
    return;
}

// end main.zig
