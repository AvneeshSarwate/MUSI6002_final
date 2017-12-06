float colourDistance(vec3 e1, vec3 e2) {
  float rmean = (e1.r + e2.r ) / 2.;
  float r = e1.r - e2.r;
  float g = e1.g - e2.g;
  float b = e1.b - e2.b;
  return sqrt((((512.+rmean)*r*r)/256.) + 4.*g*g + (((767.-rmean)*b*b)/256.));
}

float sinN(float t){
   return (sin(t) + 1.) / 1.; 
}

float cosN(float t){
   return (cos(t) + 1.) / 1.; 
}

vec3 diffColor(){
    vec2 stN = uvN();
    stN = rotate(vec2(0.5+sin(time)*0.5, 0.5+cos(time)*0.5), stN, sin(time));
    
    vec2 segGrid = vec2(floor(stN.x*30.0 * sin(time/7.)), floor(stN.y*30.0 * sin(time/7.)));

    vec2 xy;
    float noiseVal = rand(stN)*sin(time/7.) * 0.15;
    if(mod(segGrid.x, 2.) == mod(segGrid.y, 2.)) xy = rotate(vec2(sinN(time), cosN(time)), stN.xy, time + noiseVal);
    else xy = rotate(vec2(sinN(time), cosN(time)), stN.xy, - time - noiseVal);
    
    float section = floor(xy.x*30.0 * sin(time/7.)); 
    float tile = mod(section, 2.);

    float section2 = floor(xy.y*30.0 * cos(time/7.)); 
    float tile2 = mod(section2, 2.);
    float timeMod = time - (1. * floor(time/1.)); 
    
    return vec3(tile, tile2, timeMod);
}


vec3 lum(vec3 color){
    vec3 weights = vec3(0.212, 0.7152, 0.0722);
    return vec3(dot(color, weights));
}

vec3 quant(vec3 num, float quantLevels){
    vec3 roundPart = floor(fract(num*quantLevels)*2.);
    return (floor(num*quantLevels)+roundPart)/quantLevels;
}

float quant(float num, float quantLevels){
    float roundPart = floor(fract(num*quantLevels)*2.);
    return (floor(num*quantLevels)+roundPart)/quantLevels;
}


float wrap(float val, float low, float high){
    if(val < low) return low + (low-val);
    if(val > high) return high - (val - high);
    return val;
}

vec3 block() {
    vec2 stN = uvN();
    vec3 cam = texture2D(channel0, vec2(1.-stN.x, stN.y)).xyz; 
    vec3 lumC = lum(cam);
    float numBlocks = 50.+ sinN(time/2.) * 40.;
    vec2 res = gl_FragCoord.xy / stN;
    vec2 blockSize = res.xy / numBlocks;
    vec2 blockStart = floor(gl_FragCoord.xy / blockSize) * blockSize / res.xy;
    vec3 blockAvgLuma = vec3(0.);
    vec2 counter = blockStart;
    
    vec2 inc = vec2(1. / (numBlocks *100.));
    for(float i = 0.; i < 10.; i += 1.){
        for(float j = 0.; j < 10.; j += 1.){
            blockAvgLuma += lum(texture2D(channel0, vec2(1.-counter.x, counter.y)).xyz);
            counter += inc;
        }
    }
    blockAvgLuma /= 100.;
    
    return quant(blockAvgLuma, 7.+sinN(time/1.5)*10.);
}

void main () {
    vec2 stN = uvN();
    vec3 snap = texture2D(channel3, vec2(1. -stN.x, stN.y)).rgb;  
    vec3 cam = texture2D(channel0, vec2(1. -stN.x, stN.y)).rgb;  
    vec3 bb = texture2D(backbuffer, vec2(stN.x, stN.y)).rgb;
    vec3 t1 = texture2D(channel1, vec2(1. -stN.x, stN.y)).rgb;  
    vec3 col = diffColor();

    vec3 c;
    float lastFeedback = texture2D(backbuffer, vec2(stN.x, stN.y)).a; 
    float feedback; 
    float decay = 0.975;
    vec3 blockColor = block();
    
    if(colourDistance(cam, snap) > 0.6){
        if(lastFeedback < 1.) {
            feedback = 1.;
            c = col * sqrt(sqrt(blockColor));
        } else {
            feedback = lastFeedback * decay;
            c = mix(snap, bb, lastFeedback);
        }
    }
    else {
        feedback = lastFeedback * decay;
        if(lastFeedback > 0.5) {
            c = mix(snap, col * sqrt(sqrt(blockColor)), lastFeedback); //swap col for bb for glitchier effect
        } else {
            c = t1;
        }
    }
    
    gl_FragColor = vec4(c, feedback);
}