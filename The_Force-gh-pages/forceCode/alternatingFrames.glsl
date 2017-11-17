int modint(int a, int b){
    return a - a*(a/b);
}
void main () {
    vec2 stN = uvN();
    
    vec3 t1 =  texture2D(channel0, stN.xy).rgb;
    vec3 t2 =  texture2D(channel1, stN.xy).rgb;
    vec3 bb = texture2D(backbuffer, stN).rgb;
    vec3 c;
    
    if(modint(int(floor(time * 2.)), 2) == 0) c = bb.gbr;
    else c = bb;
    // c = t1;
    gl_FragColor = vec4(c, 1);
}







void main () {
    vec2 stN = uvN();
    
    vec3 t1 =  texture2D(channel0, stN.xy).rgb;
    vec3 t2 =  texture2D(channel1, stN.xy).rgb;
    vec3 bb = texture2D(backbuffer, stN).rgb;
    vec3 c;
    
    if(mod(floor(time * 2.), 2.) == 0.) c = bb.gbr;
    else c = bb;
    // c = t1;
    gl_FragColor = vec4(c, 1);
}