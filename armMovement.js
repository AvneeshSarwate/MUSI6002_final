inlets = 1;
outlets = 2;

var camMatrix = new JitterMatrix("camMatrix");
var backgroundMatrix;
var xDim = camMatrix.dim[0];
var yDim = camMatrix.dim[1];
var diffMatrix = new JitterMatrix("diffMatrix", 1, "float32", xDim, yDim);

var captureBackground = false;
var colDistThresh = 0.1;

//modulus function defined to wrap around both sides
function mod(number, modulus){ return ((number%modulus)+modulus)%modulus}	

//for convenience
var fl = Math.floor;
 
//variable that works as a "lock" to prevent overloading. not sure if necessary
var calculationOccuring = false;

function bang(){
	if(captureBackground){
		backgroundMatrix.frommatrix(camMatrix);
		captureBackground = false;
	}
	if(backgroundMatrix) {
		outlet(1, calculateCenterOfMass());
	}
	outlet(0, "jit_matrix", diffMatrix.name);
}

function calculateCenterOfMass() {
	var weightedSums = [0, 0, 0, 0] //left xy, right xy
	var sums = [0, 0, 0, 0];
	
	for(var i = 0; i < xDim; i++) {
		for(var j = 0; j < yDim; j++) {
			var camColor = camMatrix.getcell(i, j);
			var backgroundColor = backgroundMatrix.getcell(i, j);
			var colDist = colourDistance(camColor, backgroundColor)/765;
			colDist = colDist > colDistThresh ? colDist : 0;
			diffMatrix.setcell2d(i, j, colDist);
			if(colDist > colDistThresh) {
				if(i < xDim/2) {
					sums[0] += colDist;
					weightedSums[0] += colDist * i;
					sums[1] += colDist;
					weightedSums[1] += colDist * j;
				} else {
					sums[2] += colDist;
					weightedSums[2] += colDist * (xDim - i);
					sums[3] += colDist;		
					weightedSums[3] += colDist * j;
				}
			}
		}
	}
	
	var w = weightedSums;
	var s = sums;
	return [w[0]/s[0], w[1]/s[1], w[2]/s[2], w[3]/s[3]]; 
}

function grabBackground() {
	backgroundMatrix = new JitterMatrix("backgroundMatrix");
	captureBackground = true;
}

function colorDistThreshold(val){
	colDistThresh = val;
}

function colourDistance(e1, e2) {
  var rmean = (e1[1] + e2[1] ) / 2;
  var r = e1[1] - e2[1];
  var g = e1[2] - e2[2];
  var b = e1[3] - e2[3];
  return Math.sqrt((((512+rmean)*r*r)/256) + 4*g*g + (((767-rmean)*b*b)/256));
}
