const std = @import("std");

pub fn checkOK(ok: bool) !bool {
    if (!ok) {
        std.debug.print("not ok\n", .{});
    } else std.debug.print("passes OK\n", .{});
    return ok;
}
