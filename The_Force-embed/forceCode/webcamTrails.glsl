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

vec3 diffColor2() {
    vec2 stN = uvN();
    return vec3(sinN(time * stN.x), sinN(time * stN.y), sinN(time/4.));
}

void main () {
    vec2 stN = uvN();
    vec3 snap = texture2D(channel3, vec2(1. -stN.x, stN.y)).rgb;  
    vec3 cam = texture2D(channel0, vec2(1. -stN.x, stN.y)).rgb; 
    vec3 bb = texture2D(backbuffer, vec2(stN.x, stN.y)).rgb;
    vec3 col = diffColor();

    vec3 c;
    float lastFeedback = texture2D(backbuffer, vec2(stN.x, stN.y)).a;
    float feedback; 
    float decay = 0.99;
    
    if(colourDistance(cam, snap) > 0.8){
        if(lastFeedback < 1.) {
            feedback = 1.;
            c = col;
        } else {
            feedback = lastFeedback * decay;
            c = mix(snap, bb, lastFeedback);
        }
    }
    else {
        feedback = lastFeedback * decay;
        if(lastFeedback > 0.5) {
            c = mix(snap, col, lastFeedback); //swap col for bb for glitchier effect
        } else {
            c = cam;
        }
    }
    
    gl_FragColor = vec4(c, feedback);
}