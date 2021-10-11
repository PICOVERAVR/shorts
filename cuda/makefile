SRC := main.cu
CC := nvcc
CFLAGS := -g --std=c++14
GPUFLAGS := --cudart=shared # link CUDA runtime dynamically

TARGETS := debug release

.PHONY: $(TARGETS) clean

debug: CFLAGS += -O0 --device-debug
release: CFLAGS += -O3

$(TARGETS):
	$(CC) $(SRC) $(CFLAGS) $(GPUFLAGS) -o program.out

clean:
	rm *.out
