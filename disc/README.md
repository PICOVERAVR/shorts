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

		...

        intmax_t: 8 bytes
        uintmax_t: 8 bytes
        max_align_t: 16 bytes
floats:
        float fma(x, y, z) possibly slower than x * y + z
        double fma(x, y, z) possibly slower than x * y + z
        long double fma(x, y, z) possibly slower than x * y + z

atomics:
        bool is lock-free: always
        char is lock-free: always
        char16_t is lock-free: always
        short is lock-free: always
        int is lock-free: always

		...

threads.h is present

compile-time macros:
        compiled with a c compiler
        assertions enabled (debug build?)
        char16_t is UTF-16 encoded
        char32_t is UTF-32 encoded

...

```

\* gcc specific behavior is also queried, but this can easily be turned off.

