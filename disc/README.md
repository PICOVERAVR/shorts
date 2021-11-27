# Macro Printer
This program attempts to discover as much as possible about the compiler, host, runtime behavior, etc using only\* standard C11 functions and macros.

## Example output
```
$ make
$ ./disc

C standard revision: C17 (201710)
gcc (or compatible) settings:
        compiler version: "11.1.0"
        pic: on (without GOT limits)

standard C types:
        int_fast8_t: 1 bytes, 1 byte aligned
        uint_fast8_t: 1 bytes, 1 byte aligned
        int_fast16_t: 8 bytes, 8 byte aligned
        uint_fast16_t: 8 bytes, 8 byte aligned
        int_fast32_t: 8 bytes, 8 byte aligned
        uint_fast32_t: 8 bytes, 8 byte aligned
        int_fast64_t: 8 bytes, 8 byte aligned
        uint_fast64_t: 8 bytes, 8 byte aligned

        int_least8_t: 1 bytes, 1 byte aligned
        uint_least8_t: 1 bytes, 1 byte aligned
        int_least16_t: 2 bytes, 2 byte aligned
        uint_least16_t: 2 bytes, 2 byte aligned
        int_least32_t: 4 bytes, 4 byte aligned
        uint_least32_t: 4 bytes, 4 byte aligned
        int_least64_t: 8 bytes, 8 byte aligned
        uint_least64_t: 8 bytes, 8 byte aligned

        intmax_t: 8 bytes
        uintmax_t: 8 bytes
        max_align_t: 16 bytes
        size_t: 8 bytes
        wchar_t: 4 bytes, 4 byte aligned

        intptr_t: 8 bytes, 8 byte aligned
        uintptr_t: 8 bytes, 8 byte aligned
        ptrdiff_t: 8 bytes, 8 byte aligned

floats:
        float fma(x, y, z) possibly slower than x * y + z
        double fma(x, y, z) possibly slower than x * y + z
        long double fma(x, y, z) possibly slower than x * y + z

atomics:
        bool is lock-free: always
        char is lock-free: always
        char16_t is lock-free: always
        char32_t is lock-free: always
        wchar_t is lock-free: always
        short is lock-free: always
        int is lock-free: always
        long is lock-free: always
        long long is lock-free: always
        pointer is lock-free: always

threads.h is present

compile-time macros:
        compiled with a c compiler
        assertions enabled (debug build?)
        char16_t is UTF-16 encoded
        char32_t is UTF-32 encoded
...

```

\* gcc specific behavior is also queried, but this can easily be turned off.

