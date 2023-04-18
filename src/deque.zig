// Deque - generalized double-ended queue/linked list

const std = @import("std");
const mem = std.mem;

const DequeErr = error{
    EmptyList,
};

pub fn init(comptime T: anytype, comptime A: mem.Allocator) type {
    const NodeT = struct {
        const Self = @This();

        value: T,
        prev: ?*Self,
        next: ?*Self,

        pub fn init(V: T) !*Self {
            var ptr = try A.create(Self);
            ptr.value = V;
            ptr.prev = null;
            ptr.next = null;
            return ptr;
        }

        /// Return the pointer to the previous node
        pub fn prev(N: *Self) ?*Self {
            return N.prev;
        }

        /// Return the pointer to the next node
        pub fn next(N: *Self) ?*Self {
            return N.next;
        }
    };

    return struct {
        const Self = @This();

        head: ?*NodeT,
        tail: ?*NodeT,
        length: usize,

        pub fn init() Self {
            return .{
                .head = null,
                .tail = null,
                .length = 0,
            };
        }

        /// Return if a list is actually empty or not
        pub fn is_empty(S: *Self) bool {
            return S.head == null and S.tail == null and S.length == 0;
        }

        /// Insert an element to the front of the List
        pub fn insert(S: *Self, V: T) !void {
            var new_head = try NodeT.init(V);
            S.length += 1;

            if (S.head == null) {
                // insert at front, set tail to head
                S.head = new_head;
                S.tail = new_head;
                return;
            }

            // set new_head.next to S.head
            new_head.next = S.head;
            S.head = new_head;
            return;
        }

        /// Append an item to the end of the list
        pub fn append(S: *Self, V: T) !void {
            var new_tail = try NodeT.init(V);
            S.length += 1;

            if (S.tail == null) {
                // if tail is null, then list is empty
                // repeat similar logic to that of .insert()
                S.head = new_tail;
                S.tail = new_tail;
                return;
            }

            S.tail.?.*.next = new_tail;
            S.tail = new_tail;
            return;
        }

        /// Pop the front item from the list, deallocate it from the list
        pub fn pop_front(S: *Self) !T {
            if (S.head == null) {
                return DequeErr.EmptyList;
            }

            const v = S.head.?.*.value;
            const destroy_me = S.head;
            S.head = S.head.?.*.next;
            A.destroy(destroy_me.?);

            S.length -= 1;
            if (S.length == 0) {
                // change tail in case we're empty
                S.tail = null;
            }
            return v;
        }

        /// Opposite of pop_front, moves the tail backwards a position
        pub fn pop_back(S: *Self) !T {
            if (S.tail == null) {
                return DequeErr.EmptyList;
            }

            const v = S.tail.?.*.value;
            const destroy_me = S.tail;
            S.tail = S.tail.?.*.prev;
            A.destroy(destroy_me.?);

            S.length -= 1;
            if (S.length == 0) {
                S.tail == null;
            }
            return v;
        }

        pub fn starts_with(S: *Self, V: T) bool {
            if (S.is_empty()) {
                return false; // no items in list
            }
            return S.head.?.*.value == V;
        }

        pub fn ends_with(S: *Self, V: T) bool {
            if (S.is_empty()) {
                return false;
            }
            return S.tail.?.*.value == V;
        }

        /// Check if this deque is equivalent to another in value only
        pub fn equal(S: *Self, O: *Self) bool {
            _ = S;
            _ = O;
            return false;
        }

        /// Perform a deep copy and return a new list
        /// This performs an allocation and must be free'd later on
        pub fn deep_clone(S: *Self) *Self {
            var new_list = A.create(Self);

            var ptr = S.head;

            while (ptr != null) : (ptr = ptr.?.*.next) {
                new_list.append(ptr.?.*.value);
            }

            return new_list;
        }

        /// Deallocate every node in the list and set length to zero
        pub fn clear(S: *Self) void {
            var destroy_me = S.head;
            var im_next = S.head;

            while (destroy_me != null) {
                im_next = destroy_me.?.*.next;
                A.destroy(destroy_me.?);
                destroy_me = im_next;
            }

            // reset state of the list to empty/null/zero
            S.length = 0;
            S.head = null;
            S.tail = null;
            return;
        }

        /// Dealloc all nodes and dealloc the list itself
        /// Useful for destroying deep copies of the list
        pub fn destroy(S: *Self) void {
            S.clear(); // dealloc all nodes
            A.destroy(S);
            return;
        }

        /// Similar to foreach() in JS
        /// Requires function to be void (no errors)
        pub fn foreach(S: *Self, fun: *const fn (T) void) void {
            var ptr = S.head;
            while (ptr != null) : (ptr = ptr.?.*.next) {
                fun(ptr.?.*.value);
            }
            return;
        }
    };
}

test "Do tests work?" {}

// end deque.zig

