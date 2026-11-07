#pragma once
#include <cstddef>

namespace tlbb::login {
// The game's secure edit box accepts at most 32 characters. This input path
// sends one ASCII character event at a time, matching the reference client.
inline bool validPasswordInput(const char *value, size_t capacity, size_t &length) {
    length=0;
    if(!value || !capacity) return false;
    for(size_t i=0;i<capacity;++i){
        const auto c=static_cast<unsigned char>(value[i]);
        if(!c){length=i;return i>0 && i<=32;}
        if(c<0x20 || c>0x7e || i>=32) return false;
    }
    return false;
}
template<class Send> bool sendPasswordInput(const char *value,size_t capacity,Send send){
    size_t length=0;if(!validPasswordInput(value,capacity,length))return false;
    for(size_t i=0;i<length;++i)if(!send(static_cast<unsigned char>(value[i])))return false;
    return true;
}
}
