module hashmap;

import core.stdc.stdlib;

private static size_t pow2ceil(size_t num) {
    size_t power = 1;
    while (power < num) {
        power *= 2;
    }
    return power;
}

struct Hashmap(K, V, alias hashfn, alias eqfn) {
    struct Entry {
        K key;
        V val;
        bool filled;
    }

    Entry* entries;
    size_t cap;
    size_t len;

    static bool alloc(Hashmap* map, size_t caphint) {
        map.len = 0;
        map.cap = pow2ceil(caphint);

        map.entries = cast(Entry*) calloc(map.cap, Entry.sizeof);
        if (!map.entries) {
            return false;
        }
        return true;
    }

    void free() {
        .free(this.entries);
    }

    V get(K key) {
        return get(key, null);
    }

    V get(K key, bool* found) {
        ulong hash = hashfn(key);
        size_t idx = hash & (this.cap - 1);

        while (this.entries[idx].filled) {
            if (eqfn(this.entries[idx].key, key)) {
                if (found) *found = true;
                return this.entries[idx].val;
            }
            idx++;
            if (idx >= this.cap) {
                idx = 0;
            }
        }
        if (found) *found = false;

        V val;
        return val;
    }
    
    private bool resize(size_t newcap) {
        Entry* entries = cast(Entry*) calloc(newcap, Entry.sizeof);
        if (!entries) {
            return false;
        }

        Hashmap newmap = {
            entries: entries,
            cap: newcap,
            len: this.len,
        };

        for (size_t i = 0; i < this.cap; i++) {
            Entry ent = this.entries[i];
            if (ent.filled) {
                newmap.put(ent.key, ent.val);
            }
        }

        .free(this.entries);

        this.cap = newmap.cap;
        this.entries = newmap.entries;

        return true;
    }

    bool put(K key, V val) {
        if (this.len >= this.cap / 2) {
            bool ok = resize(this.cap * 2);
            if (!ok) {
                return false;
            }
        }

        ulong hash = hashfn(key);
        size_t idx = hash & (this.cap - 1);

        while (this.entries[idx].filled) {
            if (eqfn(this.entries[idx].key, key)) {
                this.entries[idx].val = val;
                return true;
            }
            idx++;
            if (idx >= this.cap) {
                idx = 0;
            }
        }

        this.entries[idx].key = key;
        this.entries[idx].val = val;
        this.entries[idx].filled = true;
        this.len++;

        return true;
    }

    private void rmidx(size_t idx) {
        this.entries[idx].filled = false;
        this.len--;
    }

    bool remove(K key) {
        ulong hash = hashfn(key);
        size_t idx = hash & (this.cap - 1);

        while (this.entries[idx].filled && !eqfn(this.entries[idx].key, key)) {
            idx = (idx + 1) & (this.cap - 1);
        }

        if (!this.entries[idx].filled) {
            return true;
        }

        rmidx(idx);

        idx = (idx + 1) & (this.cap - 1);

        while (this.entries[idx].filled) {
            K krehash = this.entries[idx].key;
            V vrehash = this.entries[idx].val;
            rmidx(idx);
            put(krehash, vrehash);
            idx = (idx + 1) & (this.cap - 1);
        }

        // halves the array if it is 12.5% full or less
        if (this.len > 0 && this.len <= this.cap / 8) {
            return resize(this.cap / 2);
        }
        return true;
    }
}
