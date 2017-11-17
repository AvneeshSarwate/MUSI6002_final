void main () {
    vec2 stN = uvN();
    
    vec3 t1 =  texture2D(channel0, stN.xy).rgb;
    vec3 t2 =  texture2D(channel1, stN.xy).rgb;
    vec3 bb = texture2D(backbuffer, stN).rgb;
    vec3 c;
    
    //given that you're close to 60 fps, the * 60 will pretty reliably get you the next sequential "frame index"
    if(mod(floor(time * 60.), 15.) == 0.) c = bb.gbr;
    else c = bb;

    gl_FragColor = vec4(c, 1);
}