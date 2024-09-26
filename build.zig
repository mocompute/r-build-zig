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
}
