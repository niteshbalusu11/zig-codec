# zig-codec

A Zig Library for Encoding and Decoding Formats

- Using Zig master branch, I am on zig version `0.12.0-dev.3352+95cb93944`. Probably any recent zig version would work.

## Installation

- In your `build.zig.zon`

```zig
    .dependencies = .{
        .zigcodec = .{
            .url = "https://github.com/niteshbalusu11/zig-codec/archive/<some-commit-hash>.tar.gz",
            // The compiler should give you the right hash to use and replace
            .hash = "12209012a6baf146acc3bb13f3f84243bba8f266b18d775b2ba84de0038319a4a159",
        },
    },
```

- In your `build.zig`

```zig
    const zigcodec = b.dependency("zigcodec", .{
        .target = target,
        .optimize = optimize,
    });

    const zig_codec_module = b.addModule("zigcodec", .{ .root_source_file = .{ .path = zigcodec.builder.pathFromRoot("src/lib.zig") } });
    exe.root_module.addImport("zigcodec", zig_codec_module);


    // IF YOU'RE USING BUILDING A LIBRARY, THEN IT'LL PROBABLY BE
    // lib.root_module.addImport("zigbase64", zig_codec_module);
```

## Example Hex Encoding and Decoding

```zig
const hex = @import("zigcodec").hex;
const std = @import("std");

test "hex encoding" {
    const allocator = std.testing.allocator;

    const original_string = "Hello, Zig!";
    const expected_hex = "48656c6c6f2c205a696721";

    const bytes = original_string;
    const hex_from_bytes = try hex.hexEncode(allocator, bytes);
    defer allocator.free(hex_from_bytes);
    try std.testing.expectEqualSlices(u8, expected_hex, hex_from_bytes);
}

test "hex decoding" {
    const allocator = std.testing.allocator;

    const original_string = "Hello, Zig!";
    const expected_hex = "48656c6c6f2c205a696721";

    const decoded_bytes = try hex.hexDecode(allocator, expected_hex);
    defer allocator.free(decoded_bytes);
    try std.testing.expectEqualSlices(u8, original_string, decoded_bytes);
}

test "is valid hex" {
    const valid_hex = "48656c6c6f2c205a696721";
    const invalid_hex = "48656c6c6f20576f726c6x";

    try std.testing.expect(hex.isHex(valid_hex));
    try std.testing.expect(!hex.isHex(invalid_hex));
}
```

## Example Base64 Encoding and Decoding

```zig
const std = @import("std");
const base64 = @import("zigcodec").base64;

test "base64 encoding" {
    const allocator = std.testing.allocator;

    const original_bytes = "Hello, Zig!";
    const expected_base64 = "SGVsbG8sIFppZyE=";

    const bytes = try base64.base64Encode(allocator, original_bytes);
    defer allocator.free(bytes);
    try std.testing.expectEqualSlices(u8, expected_base64, bytes);
}

test "base64 decoding" {
    const allocator = std.testing.allocator;

    const original_base64 = "SGVsbG8sIFppZyE=";
    const expected_bytes = "Hello, Zig!";

    const bytes = try base64.base64Decode(allocator, original_base64);
    defer allocator.free(bytes);

    try std.testing.expectEqualSlices(u8, expected_bytes, bytes);
}

test "is base64" {
    const valid_base64 = "SGVsbG8sIFppZyE=";
    const invalid_base64 = "SGVsbG8sIFppZyE =";

    try std.testing.expect(base64.isBase64(valid_base64));
    try std.testing.expect(!base64.isBase64(invalid_base64));
}
```
