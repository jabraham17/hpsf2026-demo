writeln("Hello, world!");


/* A config variable creates a command line argument */
config const n = 100;


/* 
  Creates an array of ints with indicies 1 to n
  We initialize it in serial
*/
var myArr: [1..n] int;
for i in myArr.domain {
  myArr[i] = i;
}


/* We can print the array using a forall loop, which will run in parallel */
writeln("Printing my array with domain: ", myArr.domain);
forall x in myArr {
  writeln(x);
}


/* Import some modules */
use BlockDist;
use CommDiagnostics;


/*
  Create a distributred array using a builtin helper
  We initialize like before with a serial loop
*/
var myDistribArr = blockDist.createArray({1..n}, int);
resetCommDiagnostics();
startCommDiagnostics();
for i in myDistribArr.domain {
  myDistribArr[i] = i;
}
stopCommDiagnostics();
writeln(getCommDiagnostics());

writeln("=======");

/*
  The serial loop can be slow and cause communication overhead
  we can use a forall loop to initialize in parallel and avoid communication
*/
resetCommDiagnostics();
startCommDiagnostics();
forall i in myDistribArr.domain {
  myDistribArr[i] = i;
}
stopCommDiagnostics();
writeln(getCommDiagnostics());


/* Print the array in parallel */
writeln("Printing my array with domain: ", myArr.domain);
forall x in myDistribArr {
  writeln(x);
}
