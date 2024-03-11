const std = @import("std");

pub const Base64Error = error{
    InvalidLength,
    InvalidCharacter,
};

const base64_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

/// Encodes a byte slice into a base64-encoded string.
///
/// The returned string is allocated using the provided allocator and must be freed by the caller.
pub fn base64Encode(allocator: std.mem.Allocator, data: []const u8) ![]u8 {
    const encoded_len = ((data.len + 2) / 3) * 4;
    const encoded = try allocator.alloc(u8, encoded_len);
    errdefer allocator.free(encoded);

    var i: usize = 0;
    var j: usize = 0;

    while (i < data.len) {
        const b1 = data[i];
        const b2 = if (i + 1 < data.len) data[i + 1] else 0;
        const b3 = if (i + 2 < data.len) data[i + 2] else 0;

        encoded[j] = base64_chars[(b1 >> 2) & 0x3F];
        encoded[j + 1] = base64_chars[((b1 << 4) | (b2 >> 4)) & 0x3F];
        encoded[j + 2] = if (i + 1 < data.len) base64_chars[((b2 << 2) | (b3 >> 6)) & 0x3F] else '=';
        encoded[j + 3] = if (i + 2 < data.len) base64_chars[b3 & 0x3F] else '=';

        i += 3;
        j += 4;
    }

    return encoded;
}

/// Decodes a base64-encoded string into a byte slice.
///
/// The returned byte slice is allocated using the provided allocator and must be freed by the caller.
pub fn base64Decode(allocator: std.mem.Allocator, encoded: []const u8) ![]u8 {
    if (encoded.len % 4 != 0) {
        return Base64Error.InvalidLength;
    }

    const padding = if (encoded.len > 0 and encoded[encoded.len - 1] == '=') @as(usize, 1) else 0;
    const decoded_len = (encoded.len / 4) * 3 - padding;
    const decoded = try allocator.alloc(u8, decoded_len);
    errdefer allocator.free(decoded);

    var i: usize = 0;
    var j: usize = 0;

    while (i < encoded.len) {
        const c1 = try base64CharToIndex(encoded[i]);
        const c2 = try base64CharToIndex(encoded[i + 1]);
        decoded[j] = @intCast((c1 << 2) | (c2 >> 4));

        if (i + 2 < encoded.len and encoded[i + 2] != '=') {
            const c3 = try base64CharToIndex(encoded[i + 2]);
            decoded[j + 1] = @intCast(((c2 << 4) & 0xF0) | (c3 >> 2));
        }

        if (i + 3 < encoded.len and encoded[i + 3] != '=') {
            const c3 = try base64CharToIndex(encoded[i + 2]);
            const c4 = try base64CharToIndex(encoded[i + 3]);
            decoded[j + 2] = @intCast(((c3 << 6) & 0xC0) | c4);
        }

        i += 4;
        j += 3;
    }

    return decoded;
}

/// Checks if a given string is a valid base64-encoded string.
///
/// A valid base64-encoded string must meet the following criteria:
/// - It must contain only valid base64 characters (A-Z, a-z, 0-9, +, /, =).
/// - It must have a length that is a multiple of 4.
/// - If padding is present, it must be at the end and consist of either one or two '=' characters.
///
/// Returns true if the string is a valid base64-encoded string, false otherwise.
pub fn isBase64(encoded: []const u8) bool {
    if (encoded.len % 4 != 0) {
        return false;
    }

    var padding_count: usize = 0;

    for (encoded, 0..) |char, i| {
        if (char == '=') {
            padding_count += 1;
            if (padding_count > 2 or i < encoded.len - 2) {
                return false;
            }
        } else if (!isBase64Char(char)) {
            return false;
        }
    }

    return true;
}

fn isBase64Char(char: u8) bool {
    return switch (char) {
        'A'...'Z', 'a'...'z', '0'...'9', '+', '/' => true,
        else => false,
    };
}

fn base64CharToIndex(char: u8) !u8 {
    if (char >= 'A' and char <= 'Z') {
        return char - 'A';
    } else if (char >= 'a' and char <= 'z') {
        return char - 'a' + 26;
    } else if (char >= '0' and char <= '9') {
        return char - '0' + 52;
    } else if (char == '+') {
        return 62;
    } else if (char == '/') {
        return 63;
    } else if (char == '=') {
        return 0;
    } else {
        return Base64Error.InvalidCharacter;
    }
}
