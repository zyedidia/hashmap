hashmap_test: hashmap.d hashmap_test.d
	ldc2 -betterC -O2 $^ -of $@

hashmap.o: hashmap.d
	ldc2 -betterC -O2 $^ -c -of $@

clean:
	rm -f *.o hashmap_test

.PHONY: clean
