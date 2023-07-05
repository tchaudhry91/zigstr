/// Helper lib to assist with common string operations.
const std = @import("std");
const testing = std.testing;

// Reverse a string. The memory is managed by the user.
pub fn reverse(allocator: std.mem.Allocator, s: []const u8) ![]const u8 {
    var len = s.len;
    var result: []u8 = try allocator.alloc(u8, len);

    for (s, 0..) |c, i| {
        result[len - i - 1] = c;
    }

    return result;
}

test "reverse" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var alloc = arena.allocator();
    const inputs = [_][]const u8{
        "hello",
        "world",
        "hello, world",
        "abab",
    };
    const expecteds = [_][]const u8{
        "olleh",
        "dlrow",
        "dlrow ,olleh",
        "baba",
    };

    for (inputs, 0..) |s, i| {
        const expected = expecteds[i];
        const actual = try reverse(alloc, s);
        try testing.expectEqualStrings(expected, actual);
    }
}

/// Compares the two strings for equality.
pub fn compare(a: []const u8, b: []const u8) bool {
    if (a.len != b.len) {
        return false;
    }
    for (a, b) |ac, bc| {
        if (ac != bc) {
            return false;
        }
    }
    return true;
}

test "compare" {
    const inputs = [_][]const u8{
        "hello",
        "world",
        "hello, world",
        "abab",
        "bab",
        "aab",
        "ab",
    };
    const inputs2 = [_][]const u8{
        "hello",
        "world",
        "hello, world",
        "abab",
        "abab",
        "aaa",
        "ab",
    };

    const expecteds = [_]bool{
        true,
        true,
        true,
        true,
        false,
        false,
        true,
    };

    for (inputs, inputs2, expecteds) |a, b, expected| {
        const actual = compare(a, b);
        try testing.expectEqual(expected, actual);
    }
}

/// Split the string into chunks based on a delimiter.
pub fn split(allocator: std.mem.Allocator, s: []const u8, sep: u8) ![][]const u8 {
    var result: std.ArrayList([]const u8) = std.ArrayList([]const u8).init(allocator);
    var it = std.mem.tokenizeScalar(u8, s, sep);
    while (it.next()) |token| {
        try result.append(token);
    }
    return result.toOwnedSlice();
}

test "split" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var allocator = arena.allocator();
    const inputs = [_][]const u8{
        "hello world",
        "ab ab",
        "abab",
        "a  b",
    };
    const expected = [_][]const []const u8{
        &[_][]const u8{
            "hello",
            "world",
        },
        &[_][]const u8{
            "ab",
            "ab",
        },
        &[_][]const u8{
            "abab",
        },
        &[_][]const u8{
            "a",
            "b",
        },
    };
    for (inputs, 0..) |s, i| {
        const split_s = try split(allocator, s, ' ');
        try testing.expectEqual(expected[i].len, split_s.len);
        for (split_s, 0..) |token, j| {
            try testing.expectEqualStrings(expected[i][j], token);
        }
    }
}
