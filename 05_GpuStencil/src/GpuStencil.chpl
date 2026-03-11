
/*
  Declare a simple GPU kernel to do the stencil
  Note that nothing about this is gpu specific, you could reuse this kernel
  on the CPU as well
*/
proc myStencilKernel(arr, ref next, dom) {
  forall i in dom {
    next[i] = (arr[i-1] + arr[i] + arr[i+1]) / 3.0;
  }
}

proc myStencil(arr, dom) {
  var next: arr.type;

  coforall l in dom.targetLocales() do on l {
    var localDom = dom.localSubdomain().expand(1);
    /* move computation to one of the GPUs */
    on here.gpus[0] {
      /* copy the arrays to GPU memory, then call the stencil */
      var gpuArr = arr[localDom];
      var gpuNext = next[localDom];
      myStencilKernel(gpuArr, gpuNext, gpuArr.domain.expand(-1));
      next[localDom] = gpuNext;
    }
  }

  return next;
}

config const n = 100;
writeln("Running stencil on GPU with n=", n, "here=", here.gpus.size);


use StencilDist;
const dataDom = {1..n} dmapped new stencilDist({1..n}, fluff=(1,));
const haloDom = dataDom.expand(1);

var myArr: [haloDom] real;
use Random;
fillRandom(myArr, 0.0, 100.0);

writeln("Original array:");
writeln(myArr[dataDom]);

use CommDiagnostics, GpuDiagnostics;
resetGpuDiagnostics();
startGpuDiagnostics();
resetCommDiagnostics();
startCommDiagnostics();
var nextArr = myStencil(myArr, dataDom);
stopCommDiagnostics();
stopGpuDiagnostics();
writeln(getCommDiagnostics());
writeln(getGpuDiagnostics());

writeln("Next array:");
writeln(nextArr[dataDom]);




proc myStencilMultiGpu(arr, dom) {
  var next: arr.type;

  coforall l in dom.targetLocales() do on l {
    var localDom = dom.localSubdomain().expand(1);
    const chunkSize = localDom.size / here.gpus.size;
    /* Instead of using one GPU, we can chunk our data across all GPUs */
    coforall (g, i) in zip(here.gpus, 0..) do on g {
      var gpuDom = localDom[i*chunkSize..#chunkSize]; 
      var gpuArr = arr[gpuDom];
      var gpuNext = next[gpuDom];
      myStencilKernel(gpuArr, gpuNext, gpuArr.domain.expand(-1));
      next[gpuDom] = gpuNext;
    }
  }

  return next;
}


resetCommDiagnostics();
startCommDiagnostics();
nextArr.updateFluff();
stopCommDiagnostics();
writeln(getCommDiagnostics());

resetGpuDiagnostics();
startGpuDiagnostics();
resetCommDiagnostics();
startCommDiagnostics();
var nextArr2 = myStencilMultiGpu(nextArr, dataDom);
stopCommDiagnostics();
stopGpuDiagnostics();
writeln(getCommDiagnostics());
writeln(getGpuDiagnostics());

writeln("Next array:");
writeln(nextArr2[dataDom]);



use CTypes;
extern proc myStencilInHip(n: c_int, haloSize: c_int,
                           arr: c_ptrConst(c_double),
                           next: c_ptr(c_double));

proc myStencilCallingHip(arr, dom) {
  var next: arr.type;

  coforall l in dom.targetLocales() do on l {
    var localDom = dom.localSubdomain().expand(1);
    const chunkSize = localDom.size / here.gpus.size;
    /* Instead of using one GPU, we can chunk our data across all GPUs */
    coforall (g, i) in zip(here.gpus, 0..) do on g {
      var gpuDom = localDom[i*chunkSize..#chunkSize];
      myStencilInHip(gpuDom.size:c_int, 1,
                    c_addrOfConst(arr.localAccess[gpuDom.low]),
                    c_addrOf(next.localAccess[gpuDom.low]));
    }
  }

  return next;
}


resetCommDiagnostics();
startCommDiagnostics();
nextArr2.updateFluff();
stopCommDiagnostics();
writeln(getCommDiagnostics());


resetGpuDiagnostics();
startGpuDiagnostics();
resetCommDiagnostics();
startCommDiagnostics();
var nextArr3 = myStencilCallingHip(nextArr2, dataDom);
stopCommDiagnostics();
stopGpuDiagnostics();
writeln(getCommDiagnostics());
writeln(getGpuDiagnostics());

writeln("Next array:");
writeln(nextArr3[dataDom]);
