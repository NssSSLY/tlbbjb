#pragma once
#include <windows.h>

namespace tlbb {
// String32::c_str emits UTF-8. Native server/map std::strings use a separate GBK codec.
inline bool decodeCeguiUtf8(const char *bytes, int length, wchar_t *out, int capacity) {
    if (!out || capacity < 1) return false;
    out[0] = 0;
    if (!bytes || length < 0 || length > 512) return false;
    if (length == 0) return true;
    const int needed = MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, bytes, length, nullptr, 0);
    if (needed < 1 || needed >= capacity) return false;
    const int written = MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, bytes, length, out, capacity-1);
    if (written != needed) { out[0] = 0; return false; }
    out[written] = 0;
    return true;
}
}
