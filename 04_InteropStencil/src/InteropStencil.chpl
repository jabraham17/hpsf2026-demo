
use CTypes;

extern proc myStencilInC(n: c_int, haloSize: c_int,
                         arr: c_ptrConst(c_double),
                         next: c_ptr(c_double));

proc myStencilCallingC(arr, dom) {
  var next: arr.type;

  /* for each locale of the data */
  coforall l in dom.targetLocales() do on l {
    /* get the indicies of the data on this locale (including the fluff) */
    var localDom = dom.localSubdomain().expand(1);
    /* call the C function, passing it the addresses of the local data */
    myStencilInC(localDom.size:c_int, 1,
                 c_addrOfConst(arr.localAccess[localDom.low]),
                 c_addrOf(next.localAccess[localDom.low]));
  }

  return next;
}

config const n = 100;

use StencilDist;
const dataDom = {1..n} dmapped new stencilDist({1..n}, fluff=(1,));
const haloDom = dataDom.expand(1);

var myArr: [haloDom] real;
use Random;
fillRandom(myArr, 0.0, 100.0);

writeln("Original array:");
writeln(myArr[dataDom]);

use CommDiagnostics;
resetCommDiagnostics();
startCommDiagnostics();
var nextArr = myStencilCallingC(myArr, dataDom);
stopCommDiagnostics();
writeln(getCommDiagnostics());

writeln("Next array from C:");
writeln(nextArr[dataDom]);








/*
  The language we use doesn't matter that much, we can use fortran too!
*/
extern proc myStencilInFortran(n: c_int, haloSize: c_int,
                               arr: c_ptrConst(c_double),
                               next: c_ptr(c_double));

proc myStencilCallingFortran(arr, dom) {
  var next: arr.type;

  coforall l in dom.targetLocales() do on l {
    var localDom = dom.localSubdomain().expand(1);
    myStencilInFortran(localDom.size:c_int, 1,
                       c_addrOfConst(arr.localAccess[localDom.low]),
                       c_addrOf(next.localAccess[localDom.low]));
  }

  return next;
}


/*
  reuse the previous array and do another "iteration"

  To do that, we need to update the halo
*/
resetCommDiagnostics();
startCommDiagnostics();
nextArr.updateFluff();
stopCommDiagnostics();
writeln(getCommDiagnostics());

resetCommDiagnostics();
startCommDiagnostics();
var nextArr2 = myStencilCallingFortran(nextArr, dataDom);
stopCommDiagnostics();
writeln(getCommDiagnostics());

writeln("Next array from fortran:");
writeln(nextArr2[dataDom]);

