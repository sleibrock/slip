// btree.zig - a binary tree implemented in zig

// Tree in Haskell:
// BTree a = Tree (Maybe Btree a) (Maybe Btree a)

const std = @import("std");
const mem = std.mem;

pub fn init(comptime T: anytype, comptime Cmp: fn (*T, *T) bool, A: mem.Allocator) type {
    return struct {
        const Self = @This();

        current: ?*T,
        left: ?*Self,
        right: ?*Self,

        pub fn init() Self {
            return .{
                .current = null,
                .left = null,
                .right = null,
            };
        }

        pub fn insert(S: *Self, val: *T) void {
            if (current == null) {
                S.current = val;
                return;
            }

            if (Cmp(val, S.current)) {
                // left branch
                if (S.left == null) {
                    // left branch wasn't allocated yet
                    return;
                }
                return;
            }
            // right branch
            if (S.right == null) {
                // right branch wasn't allocated yet
                return;
            }
            return;
        }
    };
}

// end btree.zig
