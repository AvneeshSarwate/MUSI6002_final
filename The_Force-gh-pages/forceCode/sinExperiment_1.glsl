
void main () {
    vec2 st = uv(); vec2 stN = uvN();
    float theta = atan(st.x, st.y)/PI2 +.5; float phi = log(length(st)) * .8;
    vec3 c = black;

    float f = noise(vec2(st.y + msg2.y, 1));
    f = pow(f, 3.) * 15.;
    float f2 = noise(vec2(st.y + msg2.z, 1));
    f2 = pow(f2, 2.) * 15.;
    float f3 = noise(vec2(st.y + msg2.w, 1));
    f3 = pow(f3, 1.) * 15.;

    c += f * blue + f2 * yellow + f3 * red;
    
    float ff = noise(rotate(stN * 5., vec2(5., 5.), 1. * .1));
    //  c =  step(bands.x, ff);
    c *= ff;
    //  c *=  ff * 30.;

    vec3 bb =  texture2D(backbuffer, stN).rgb;
    c = mix(c, bb, .0) + c * .0;
    
    stN = rotate(vec2(0.5, 0.5), stN, sin(time));
    
    vec2 segGrid = vec2(floor(stN.x*30.0 * sin(time/7.)), floor(stN.y*30.0 * sin(time/7.)));
    // float rotation =  sin(time / 1.) * (4. - rand(stN)*0.1);
    // vec2 xy = rotate(vec2(msg2.x, msg2.y), stN.xy, rotation);
    vec2 xy;
    if(mod(segGrid.x, 2.) == mod(segGrid.y, 2.)) xy = rotate(vec2(msg2.x, msg2.y), stN.xy, time + rand(stN)*sin(time));
    else xy = rotate(vec2(msg2.x, msg2.y), stN.xy, - time - rand(stN)*sin(time));
    float m2 = mod(10., 5.);
    
    float r = st.x;
    float section = floor(xy.x*30.0 * sin(time/7.));
    float tile = mod(section, 2.);
    float section2 = floor(xy.y*30.0 * cos(time/7.));
    float tile2 = mod(section2, 2.);
    float timeMod = time - (1. * floor(time/1.));

    gl_FragColor = vec4(tile, tile2, timeMod, 1);
}