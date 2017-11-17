
void main () {
    vec2 stN = uvN();
    
    stN = rotate(vec2(0.5+sin(time)*0.5, 0.5+cos(time)*0.5), stN, sin(time));
    
    vec2 segGrid = vec2(floor(stN.x*30.0 * sin(time/7.)), floor(stN.y*30.0 * sin(time/7.)));

    vec2 xy;
    if(mod(segGrid.x, 2.) == mod(segGrid.y, 2.)) xy = rotate(vec2(msg2.x, msg2.y), stN.xy, time + rand(stN)*sin(time/7.));
    else xy = rotate(vec2(msg2.x, msg2.y), stN.xy, - time - rand(stN)*sin(time/7.));
    
    float section = floor(xy.x*30.0 * sin(time/7.));
    float tile = mod(section, 2.);

    float section2 = floor(xy.y*30.0 * cos(time/7.));
    float tile2 = mod(section2, 2.);
    
    float timeMod = time - (1. * floor(time/1.));

    gl_FragColor = vec4(tile, tile2, timeMod, 1);
}