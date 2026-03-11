
/* a simple stencil code in Chapel */
proc myStencil(arr, dom) {
  /* declare the output array with the same type as the input */
  var next: arr.type;

  /* iterate over our iteration domain and compute a mean of the 3 elements */
  forall i in dom {
    next[i] = (arr[i+1] + arr[i] + arr[i-1]) / 3;
  }

  return next;
}


config const n = 100;

/*
  declare two distributed domains
  dataDom is the indicies we care about and what we will use to iterate
  haloDom is the indicies we will actually use to allocate an array
*/
use BlockDist;
const dataDom = {1..n} dmapped new blockDist({1..n});
const haloDom = dataDom.expand(1);


/* initialize the array with the halo region */
var myArr: [haloDom] real;
use Random;
fillRandom(myArr, 0.0, 100.0);


/* print the original array */
writeln("Original array:");
writeln(myArr[dataDom]);


/* call the stencil function */
use CommDiagnostics;
resetCommDiagnostics();
startCommDiagnostics();
var nextArr = myStencil(myArr, dataDom);
stopCommDiagnostics();
writeln(getCommDiagnostics());

/* print the new array */
writeln("Next array:");
writeln(nextArr[dataDom]);



/*
  There is excess communication, lets use something more specialized

  the stencil distribution will duplicate the halo elements and avoid
  communication for the stencil operation
*/
use StencilDist;
const dataDom2 = {1..n} dmapped new stencilDist({1..n}, fluff=(1,));
const haloDom2 = dataDom2.expand(1);

var myArr2: [haloDom2] real;
fillRandom(myArr2, 0.0, 100.0);

writeln("Original array:");
writeln(myArr2[dataDom2]);

resetCommDiagnostics();
startCommDiagnostics();
var nextArr2 = myStencil(myArr2, dataDom2);
stopCommDiagnostics();
writeln(getCommDiagnostics());

writeln("Next array:");
writeln(nextArr2[dataDom2]);
