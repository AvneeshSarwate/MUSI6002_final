inlets = 1;
outlets = 2;

var camMatrix = new JitterMatrix("camMatrix");
var backgroundMatrix = new JitterMatrix("backgroundMatrix");
var xDim = camMatrix.dim[0];
var yDim = camMatrix.dim[1];

var captureBackground = false;

//modulus function defined to wrap around both sides
function mod(number, modulus){ return ((number%modulus)+modulus)%modulus}	

//for convenience
var fl = Math.floor;

//variable that works as a "lock" to prevent overloading. not sure if necessary
var calculationOccuring = false;

function bang(){
	post(camMatrix.getcell(0, 0));
	post();
	if(captureBackground){
		backgroundMatrix.frommatrix(camMatrix);
		captureBackground = false;
	}
}

function calculateCenterOfMass() {
	var weightedSums = [0, 0, 0, 0] //left xy, right xy
	var sums = [0, 0, 0, 0];
	
	for(var i = 0; i < xDim; i++) {
		for(var j = 0; j < yDim; j++) {
			var camColor = camMatrix.getcell(i, j);
			var backgroundColor = backgroundMatrix(i, j);
			var colDist = Math.abs(colourDistance(camColor, backgroundColor);
			sums[1] += colDist;
			sums[3] += colDist;
			if(x < xDim/2) {
				
			} else {
				
			}
		}
	}
	
	var w = weightedSums;
	var s = sums;
	return [w[0]/s[0], w[1]/s[1], w[2]/s[2], w[3]/s[3]]; 
}

function grabBackground() {
	captureBackground = true;
}

function colourDistance(e1, e2) {
  var rmean = (e1[1] + e2[1] ) / 2;
  var r = e1[1] - e2[1];
  var g = e1[2] - e2[2];
  var b = e1[3] - e2[3];
  return sqrt((((512+rmean)*r*r)/256) + 4*g*g + (((767-rmean)*b*b)/256));
}
