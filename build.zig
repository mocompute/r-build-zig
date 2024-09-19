// This file is part of r-build-zig.
//
// Copyright (C) 2024 <https://codeberg.org/mocompute>
//
// r-build-zig is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// r-build-zig is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

const std = @import("std");

const Build = std.Build;
const Compile = std.Build.Step.Compile;
const Module = std.Build.Module;
const ResolvedTarget = Build.ResolvedTarget;
const OptimizeMode = std.builtin.OptimizeMode;

fn build_fetch_assets(b: *Build, target: ResolvedTarget, optimize: OptimizeMode) *Compile {
    const exe = b.addExecutable(.{
        .name = "fetch-assets",
        .root_source_file = b.path("src/fetch-assets/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const r_repo_parse = b.dependency("r-repo-parse", .{
        .target = target,
        .optimize = optimize,
    }).module("r-repo-parse");

    exe.root_module.addImport("r-repo-parse", r_repo_parse);
    return exe;
}

fn build_generate_build(
    b: *Build,
    target: ResolvedTarget,
    optimize: OptimizeMode,
) *Compile {
    const exe = b.addExecutable(.{
        .name = "generate-build",
        .root_source_file = b.path("src/generate-build/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const r_repo_parse = b.dependency("r-repo-parse", .{
        .target = target,
        .optimize = optimize,
    }).module("r-repo-parse");

    exe.root_module.addImport("r-repo-parse", r_repo_parse);

    return exe;
}

pub fn build(b: *Build) !void {
    // -- begin options ------------------------------------------------------
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    // -- end options --------------------------------------------------------

    // -- begin tools --------------------------------------------------------

    const fetch_assets = build_fetch_assets(b, target, optimize);
    b.installArtifact(fetch_assets);
    b.getInstallStep().dependOn(&fetch_assets.step);

    const generate_build = build_generate_build(
        b,
        target,
        optimize,
    );
    b.installArtifact(generate_build);
    b.getInstallStep().dependOn(&generate_build.step);

    // -- end tools ----------------------------------------------------------

    // -- begin check --------------------------------------------------------
    // const exe_check = b.addExecutable(.{
    //     .name = "r_repo_parse",
    //     .root_source_file = b.path("src/main.zig"),
    //     .target = target,
    //     .optimize = optimize,
    // });
    // exe_check.root_module.addImport("mos", mos);
    // exe_check.root_module.addImport("cmdline", cmdline);
    // exe_check.root_module.addImport("common", common);

    // const check = b.step("check", "Check if r_repo_parse compiles");
    // check.dependOn(&exe_check.step);
    // check.dependOn(&fetch_assets.step);
    // -- end check ----------------------------------------------------------

    // -- begin test ---------------------------------------------------------
    // const lib_unit_tests = b.addTest(.{
    //     .root_source_file = b.path("src/lib/root.zig"),
    //     .target = target,
    //     .optimize = optimize,
    // });
    // lib_unit_tests.root_module.addImport("common", common);
    // lib_unit_tests.root_module.addImport("mos", mos);
    // lib_unit_tests.linkLibC();

    // const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    // const exe_unit_tests = b.addTest(.{
    //     .root_source_file = b.path("src/main.zig"),
    //     .target = target,
    //     .optimize = optimize,
    // });
    // exe_unit_tests.root_module.addImport("common", common);
    // exe_unit_tests.root_module.addImport("mos", mos);

    // const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    // // Similar to creating the run step earlier, this exposes a `test` step to
    // // the `zig build --help` menu, providing a way for the user to request
    // // running the unit tests.
    // const test_step = b.step("test", "Run unit tests");
    // test_step.dependOn(&run_lib_unit_tests.step);
    // test_step.dependOn(&run_exe_unit_tests.step);
    // -- end test -----------------------------------------------------------

}
