const std = @import("std");
const helper = @import("helper.zig"); // local source file

const config = @import("config"); // from build system

extern fn foo_bar() void; // optional -- ok if missing when unused
extern fn fizzOrbuzz(n: usize) ?[*:0]const u8; // from static library
extern fn fizz_buzz(n: usize) ?[*:0]const u8; // from dynamic library

pub fn main() !void {
    std.debug.print("config version: {s}\n", .{config.version});
    // const semver = std.SemanticVersion.parse(config.version) catch unreachable;
    //if (semver.major < 1) {
    //    @compileError("need to upgrade to at least version 1.0.0; -Dversion=1.0.0");
    //}
    if (config.have_libfoo) { // comptime-known boolean
        std.debug.print("libfoo is enabled\n", .{});
        foo_bar();
    }
    _ = try helper.checkOK(true); // call pub function from local imported source file

    // get buffed stdout writer...
    const stdout = std.io.getStdOut();
    var bw = std.io.bufferedWriter(stdout.writer());
    const w = bw.writer();
    // use static library
    try w.print("static :  ", .{});
    for (1..20) |n| {
        if (fizzOrbuzz(n)) |s| {
            try w.print("{s} ", .{s});
        } else {
            try w.print("{d}  ", .{n});
        }
    }
    try w.print("\n", .{});

    // use dynamic library
    try w.print("dynamic:  ", .{});
    for (1..20) |n| {
        if (fizz_buzz(n)) |s| {
            try w.print("{s} ", .{s});
        } else {
            try w.print("{d}  ", .{n});
        }
    }
    try w.print("\n", .{});
    try bw.flush();
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit();
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

test "second test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit();
    try list.append(456);
    try std.testing.expectEqual(@as(i32, 456), list.pop());
}
