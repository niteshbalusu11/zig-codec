const std = @import("std");
const testing = std.testing;

/// Error types for the hex module.
pub const HexError = error{
    InvalidLength,
    InvalidCharacter,
};

/// Converts a hexadecimal string to a byte slice.
///
/// The hexadecimal string must have an even number of characters.
///
/// Returns an error if the input string is not a valid hexadecimal string.
///
/// Allocates memory for the returned byte slice, which must be freed by the caller.
pub fn hexDecode(allocator: std.mem.Allocator, hex_string: []const u8) ![]u8 {
    if (hex_string.len % 2 != 0) {
        return HexError.InvalidLength;
    }

    const bytes = try allocator.alloc(u8, hex_string.len / 2);
    errdefer allocator.free(bytes);

    var i: usize = 0;
    while (i < hex_string.len) : (i += 2) {
        const high_nibble = try charToNibble(hex_string[i]);
        const low_nibble = try charToNibble(hex_string[i + 1]);
        bytes[i / 2] = (high_nibble << 4) | low_nibble;
    }

    return bytes;
}

/// Converts a byte slice to a hexadecimal string.
///
/// Returns an error if try allocator.alloc fails
///
/// Allocates memory for the returned hex string, which must be freed by the caller.
pub fn hexEncode(allocator: std.mem.Allocator, bytes: []const u8) ![]u8 {
    const hex_string = try allocator.alloc(u8, bytes.len * 2);
    errdefer allocator.free(hex_string);

    const hex_chars = "0123456789abcdef";

    for (bytes, 0..) |byte, i| {
        hex_string[2 * i] = hex_chars[byte >> 4];
        hex_string[2 * i + 1] = hex_chars[byte & 0xf];
    }

    return hex_string;
}

/// Checks if a given string is a valid hexadecimal string.
///
/// A valid hexadecimal string must meet the following criteria:
/// - It must contain only hexadecimal characters (0-9, a-f, A-F).
/// - It must have an even number of characters.
///
/// Returns true if the string is a valid hexadecimal string, false otherwise.
pub fn isHex(hex_string: []const u8) bool {
    if (hex_string.len % 2 != 0) {
        return false;
    }

    for (hex_string) |char| {
        if (!isHexChar(char)) {
            return false;
        }
    }

    return true;
}

fn charToNibble(c: u8) !u8 {
    return switch (c) {
        '0'...'9' => c - '0',
        'a'...'f' => c - 'a' + 10,
        'A'...'F' => c - 'A' + 10,
        else => HexError.InvalidCharacter,
    };
}

fn isHexChar(char: u8) bool {
    return switch (char) {
        '0'...'9', 'a'...'f', 'A'...'F' => true,
        else => false,
    };
}
