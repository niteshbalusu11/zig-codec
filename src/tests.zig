const std = @import("std");
const hex = @import("./lib.zig").hex;
const base64 = @import("./lib.zig").base64;
const testing = std.testing;

test "base64 encoding" {
    const allocator = testing.allocator;

    const original_bytes = "Hello, Zig!";
    const expected_base64 = "SGVsbG8sIFppZyE=";

    const bytes = try base64.base64Encode(allocator, original_bytes);
    defer allocator.free(bytes);
    try testing.expectEqualSlices(u8, expected_base64, bytes);
}

test "base64 decoding" {
    const allocator = testing.allocator;

    const original_base64 = "SGVsbG8sIFppZyE=";
    const expected_bytes = "Hello, Zig!";

    const bytes = try base64.base64Decode(allocator, original_base64);
    defer allocator.free(bytes);

    try testing.expectEqualSlices(u8, expected_bytes, bytes);
}

test "is base64" {
    const valid_base64 = "SGVsbG8sIFppZyE=";
    const invalid_base64 = "SGVsbG8sIFppZyE =";

    try testing.expect(base64.isBase64(valid_base64));
    try testing.expect(!base64.isBase64(invalid_base64));
}

test "hex encoding" {
    const allocator = testing.allocator;

    const original_string = "Hello, Zig!";
    const expected_hex = "48656c6c6f2c205a696721";

    const bytes = original_string;
    const hex_from_bytes = try hex.hexEncode(allocator, bytes);
    defer allocator.free(hex_from_bytes);
    try testing.expectEqualSlices(u8, expected_hex, hex_from_bytes);
}

test "hex decoding" {
    const allocator = testing.allocator;

    const original_string = "Hello, Zig!";
    const expected_hex = "48656c6c6f2c205a696721";

    const decoded_bytes = try hex.hexDecode(allocator, expected_hex);
    defer allocator.free(decoded_bytes);
    try testing.expectEqualSlices(u8, original_string, decoded_bytes);
}

test "is valid hex" {
    const valid_hex = "48656c6c6f2c205a696721";
    const invalid_hex = "48656c6c6f20576f726c6x";

    try testing.expect(hex.isHex(valid_hex));
    try testing.expect(!hex.isHex(invalid_hex));
}
