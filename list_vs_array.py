#!/usr/bin/env python3

# A CS professor of mine mentioned that linked lists are much faster than arrays at insertion and deletion of middle elements.
# This is true in a theoretical context, but caches on modern CPUs are really, really effective at absorbing the penalty of copies
# if the data takes advantage of spacial and temporal locality.
# Arrays do this.  Linked lists don't.

import random
import time
import array

def insert_test(size):
    ll = []
    arr = array.array('f')

    print(f"{size} runs:")

    ll_start = time.perf_counter()
    for i in range(0, size):
        idx = random.randint(0, len(ll))
        val = random.random()
        ll.insert(idx, val)
    ll_end = time.perf_counter()

    print(f"\tlist: {ll_end - ll_start:0.4f} sec.")

    arr_start = time.perf_counter()
    for i in range(0, size):
        idx = random.randint(0, len(arr))
        val = random.random()
        arr.insert(idx, val)
    arr_end = time.perf_counter()

    print(f"\tarray: {arr_end - arr_start:0.4f} sec.")
    print(f"\tspeed increase with array: {(ll_end - ll_start) / (arr_end - arr_start):.2f}x")

def insert_delete_test(size):
    ll = [0.0] * size
    arr = array.array('f', [0.0] * size)

    print(f"{size} runs:")

    ll_start = time.perf_counter()
    for i in range(0, size):
        ins = random.choice([True, False])
        if ins == False and len(ll) > 0:
            idx = random.randint(0, len(ll) - 1)
            ll.pop(idx)
        else:
            idx = random.randint(0, len(ll))
            val = random.random()
            ll.insert(idx, val)
    ll_end = time.perf_counter()

    print(f"\tlist: {ll_end - ll_start:0.4f} sec.")

    arr_start = time.perf_counter()
    for i in range(0, size):
        ins = random.choice([True, False])
        if ins == False and len(arr) > 0:
            idx = random.randint(0, len(arr) - 1)
            arr.pop(idx)
        else:
            idx = random.randint(0, len(arr))
            val = random.random()
            arr.insert(idx, val)
    arr_end = time.perf_counter()

    print(f"\tarray: {arr_end - arr_start:0.4f} sec.")
    print(f"\tspeed increase with array: {(ll_end - ll_start) / (arr_end - arr_start):.2f}x")

def sort_test(size):
    ll = []
    arr = array.array('f')

    print(f"{size} runs:")

    for i in range(0, size):
        val = random.random()
        ll.append(val)

    ll_start = time.perf_counter()
    ll2 = sorted(ll)
    ll_end = time.perf_counter()

    print(f"\tlist: {ll_end - ll_start:0.4f} sec.")

    for i in range(0, size):
        val = random.random()
        arr.append(val)
    
    arr_start = time.perf_counter()
    arr2 = sorted(arr)
    arr_end = time.perf_counter()

    print(f"\tarray: {arr_end - arr_start:0.4f} sec.")
    print(f"\tspeed increase with array: {(ll_end - ll_start) / (arr_end - arr_start):.2f}x")

if __name__ == "__main__":
    sizes = [10, 100, 1000, 5000, 10000, 50000, 100000, 200000]

    print("insertion of float elements at random locations.")
    for size in sizes:
        insert_test(size)
    
    print("\ninsertion and deletion of float elements at random locations.")
    for size in sizes:
        insert_delete_test(size)
    
    # this is a lot quicker than straight insertions and deletions, so add additional elements
    sort_sizes = [10, 100, 1000, 5000, 10000, 50000, 100000, 200000, 500000, 1000000, 2000000, 5000000, 10000000]
    print("\nsorting float elements.")
    for size in sort_sizes:
        sort_test(size)
    