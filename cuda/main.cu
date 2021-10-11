#include <iostream>
using namespace std;

const size_t TILE_WIDTH = 16; // block width == tile width

__global__ void matmul(float* Md, float* Nd, float* outd, int width) {
	__shared__ float Mtile[TILE_WIDTH][TILE_WIDTH]; // 1 shared tile per block
	__shared__ float Ntile[TILE_WIDTH][TILE_WIDTH];
	
	int bx = blockIdx.x;
	int by = blockIdx.y;
	
	int tx = threadIdx.x;
	int ty = threadIdx.y;
	
	int row = by * TILE_WIDTH + ty; // row and column indices of resulting value
	int col = bx * TILE_WIDTH + tx;
	
	float outval = 0.0;
	for (int ntile = 0; ntile < width / TILE_WIDTH; ntile++) {
		// (ntile * TILE_WIDTH) elements have already been processed, so skip them
		Mtile[ty][tx] = Md[row * width + (ntile * TILE_WIDTH + tx)];
		Ntile[ty][tx] = Nd[(ntile * TILE_WIDTH + ty) * width + col];
		
		__syncthreads();
		
		for (int n = 0; n < TILE_WIDTH; n++) {
			outval += Mtile[ty][n] * Ntile[n][tx];
			__syncthreads();
		}
		outd[row * width + col] = outval;
	}
}

void printDeviceInfo(bool moreinfo) {
    int device;
    cudaGetDevice(&device);

    cudaDeviceProp prop;
    cudaGetDeviceProperties(&prop, device);
    
    int driver;
    cudaDriverGetVersion(&driver);
    
    int runtime;
    cudaRuntimeGetVersion(&runtime);
    
    cout << "GPU: " << prop.name << endl;
    cout << "Driver Version: " << driver << endl;
    cout << "Runtime Version: " << runtime << endl << endl;
	
	if (moreinfo) {
		cout << "warp size (threads): " << prop.warpSize << endl;
		cout << "global memory available (MiB): " << prop.totalGlobalMem / 1048576 << endl;
		cout << "shared memory available per block (bytes): " << prop.sharedMemPerBlock << endl;
		cout << "max threads per block: " << prop.maxThreadsPerBlock << endl;
		cout << "max number of blocks: (x: " << prop.maxGridSize[0] << ", y: " << prop.maxGridSize[1] << ", z: " << prop.maxGridSize[2] << ")" << endl << endl;
	}
}

int main(int argc, char **argv) {
	printDeviceInfo(true);
	
	const unsigned int width = 64;
	const unsigned int blockwidth = 16;
	
	float A[width * width] = { 0 };
	float B[width * width] = { 0 };
	
	for (int i = 0; i < width; i++) {
		A[width * i + i] = 1.0;
		B[width * i + i] = 1.0;
	}
	
	float C[width * width];
	
	float* Ad;
	float* Bd;
	float* Cd;
	
	const unsigned int size = width * width * sizeof(float);
	
	cudaMalloc((void**) &Ad, size);
	cudaMalloc((void**) &Bd, size);
	cudaMalloc((void**) &Cd, size);

	cudaMemcpy(Ad, A, size, cudaMemcpyHostToDevice);
	cudaMemcpy(Bd, B, size, cudaMemcpyHostToDevice);
	
	dim3 dimBlock(blockwidth, blockwidth, 1);
	dim3 dimGrid(width / blockwidth, width / blockwidth, 1); // dim3 = vec3, 1 for final element because grids have to be 2D
	
	matmul<<<dimGrid, dimBlock>>>(Ad, Bd, Cd, width);
	
	cudaMemcpy(C, Cd, size, cudaMemcpyDeviceToHost);
	
	for (size_t i = 0; i < width * width; i++) {
		if ((i % width == 0) && (i > 0)) {
			cout << endl;
		}
		cout << C[i] << " ";
	}
	cout << endl;
	
	cudaFree(Ad);
	cudaFree(Bd);
	cudaFree(Cd);
}
