// see: https://ziglang.org/learn/build-system/
const std = @import("std");
const test_targets = [_]std.Target.Query{
    .{}, // native
    .{
        .cpu_arch = .x86_64,
        .os_tag = .windows,
    },
    .{
        .cpu_arch = .x86_64,
        .os_tag = .linux,
    },
    .{
        .cpu_arch = .aarch64,
        .os_tag = .macos,
    },
};

pub fn build(b: *std.Build) void {
    // Project-Specific Options: https://ziglang.org/learn/build-system/#user-options
    // allow -Dwindows to target Windows
    //const windows = b.option(bool, "windows", "Target Microsoft Windows") orelse false;

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "example",
        .root_source_file = b.path("main.zig"),
        .target = target,
        //.target = b.resolveTargetQuery(.{.os_tag = if (windows) .windows else null}),
        .optimize = optimize,
    });

    // add build options...
    const options = b.addOptions();
    const version = b.option([]const u8, "version", "application version string") orelse "0.0.0";
    options.addOption([]const u8, "version", version);

    const enable_foo = detectWhetherToEnableLibFoo();
    options.addOption(bool, "have_libfoo", enable_foo);
    exe.root_module.addOptions("config", options);

    // add static library...
    const libfizzbuzz = b.addStaticLibrary(.{
        .name = "fizzbuzz",
        .root_source_file = b.path("fizzbuzz.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe.linkLibrary(libfizzbuzz); // link into executable
    b.installArtifact(libfizzbuzz); // make available

    const libfizz_buzz = b.addSharedLibrary(.{
        .name = "fizz_buzz",
        .root_source_file = b.path("fizz_buzz.zig"),
        .target = target,
        .optimize = optimize,
        .version = .{ .major = 1, .minor = 2, .patch = 3 },
    });
    b.installArtifact(libfizz_buzz);

    exe.linkLibrary(libfizzbuzz); // link static into executable
    exe.linkLibrary(libfizz_buzz); // link dynamic into executable
    b.installArtifact(exe);

    const run_step = b.step("run", "Run the application");
    const run_exe = b.addRunArtifact(exe);
    run_step.dependOn(&run_exe.step);

    const test_step = b.step("test", "Run the tests");
    for (test_targets) |tgt| {
        const unit_test = b.addTest(.{
            .root_source_file = b.path("main.zig"),
            .target = b.resolveTargetQuery(tgt),
        });

        const run_unit_tests = b.addRunArtifact(unit_test);
        run_unit_tests.skip_foreign_checks = true;
        test_step.dependOn(&run_unit_tests.step);
    }

    const install_docs = b.addInstallDirectory(.{
        .source_dir = exe.getEmittedDocs(),
        .install_dir = .prefix,
        .install_subdir = "docs",
    });

    const docs_step = b.step("docs", "Install docs into zig-out/docs");
    docs_step.dependOn(&install_docs.step);
}

fn detectWhetherToEnableLibFoo() bool {
    return false;
}
