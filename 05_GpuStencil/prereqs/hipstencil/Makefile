
LLVMBIN=$(shell $(shell $(CHPL_HOME)/util/chplenv/chpl_llvm.py --llvm-config) --bindir)
CLANG=$(shell $(CHPL_HOME)/util/chplenv/chpl_compiler.py --target --cc)
CHPL_ROCM_PATH=$(shell $(CHPL_HOME)/util/printchplenv --value --only CHPL_ROCM_PATH)
CHPL_ROCM_LLVM_BIN=$(shell $(CHPL_HOME)/util/printchplenv --value --only CHPL_ROCM_LLVM_PATH)/bin
all:
	PATH=$(PATH):$(LLVMBIN):$(CHPL_ROCM_LLVM_BIN) $(CLANG) --offload-arch=$(CHPL_GPU_ARCH) -o hipstencil.o -c hipstencil.hip -I$(CHPL_ROCM_PATH)/include -I$(CHPL_ROCM_PATH)/hip/include -Wno-unused-value

printchplflags:
	@$(info prereqs/hipstencil/hipstencil.h prereqs/hipstencil/hipstencil.o)

