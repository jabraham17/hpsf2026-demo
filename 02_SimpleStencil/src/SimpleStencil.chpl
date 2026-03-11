
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
  declare two domains
  dataDom is the indicies we care about and what we will use to iterate
  haloDom is the indicies we will actually use to allocate an array
*/
const dataDom = {1..n};
const haloDom = dataDom.expand(1);


/* initialize the array with the halo region */
var myArr: [haloDom] real;
use Random;
fillRandom(myArr, 0.0, 100.0);


/* print the original array */
writeln("Original array:");
writeln(myArr);


/* call the stencil function */
var nextArr = myStencil(myArr, dataDom);

/* print the new array */
writeln("Next array:");
writeln(nextArr);

