#include "cstencil.h"

void myStencilInC(int n, int haloSize, const double* in, double* out) {
  for (int i = haloSize; i < n - haloSize; i++) {
    out[i] = (in[i - 1] + in[i] + in[i + 1]) / 3.0;
  }
}
