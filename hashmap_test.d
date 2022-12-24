import hashmap;

import core.stdc.stdio;

ulong uint_hash(uint key) {
    key = ((key >> 16) ^ key) * 0x119de1f3;
    key = ((key >> 16) ^ key) * 0x119de1f3;
    key = (key >> 16) ^ key;
    return key;
}

bool uint_eq(uint a, uint b) {
    return a == b;
}

extern (C) void main() {
    alias UintMap = Hashmap!(uint, uint, uint_hash, uint_eq);
    UintMap map;
    UintMap.alloc(&map, 1024);

    printf("put 500: 42\n");
    map.put(500, 42);
    printf("get 500: %d\n", map.get(500));
    printf("get 501: %d\n", map.get(501));

    printf("remove 500\n");
    map.remove(500);

    printf("get 500: %d\n", map.get(500));
    printf("get 501: %d\n", map.get(501));
}
