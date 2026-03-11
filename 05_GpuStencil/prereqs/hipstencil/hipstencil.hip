#include "hipstencil.h"

#include <hip/hip_runtime.h>

__global__ void kernel(const double* in, double* out, int n, int haloSize) {
  int i = blockIdx.x * blockDim.x + threadIdx.x + haloSize;
  if (i < n - haloSize) {
    out[i] = (in[i - 1] + in[i] + in[i + 1]) / 3.0;
  }
}
extern "C" void myStencilInHip(int n, int haloSize, const double* in, double* out) {
  double* d_in;
  double* d_out;
  hipMalloc(&d_in, n * sizeof(double));
  hipMalloc(&d_out, n * sizeof(double));
  hipMemcpy(d_in, in, n * sizeof(double), hipMemcpyHostToDevice);

  int blockSize = 256;
  int numBlocks = (n + blockSize - 1) / blockSize;
  hipLaunchKernelGGL(kernel, dim3(numBlocks), dim3(blockSize), 0, 0, d_in, d_out, n, haloSize);

  hipMemcpy(out, d_out, n * sizeof(double), hipMemcpyDeviceToHost);
  hipFree(d_in);
  hipFree(d_out);
} 
