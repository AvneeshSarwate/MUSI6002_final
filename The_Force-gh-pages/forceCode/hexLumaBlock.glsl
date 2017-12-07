
vec2 cube_to_axial(vec3 cube){
    float q = cube.x;
    float r = cube.z;
    return vec2(q, r);
}

vec3 axial_to_cube(vec2 hex){
    float x = hex.x;
    float z = hex.y;
    float y = -x-z;
    return vec3(x, y, z);
}

float round(float v){
    return floor(v+0.5);
}

vec3 cube_round(vec3 cube){
    float rx = round(cube.x);
    float ry = round(cube.y);
    float rz = round(cube.z);

    float x_diff = abs(rx - cube.x);
    float y_diff = abs(ry - cube.y);
    float z_diff = abs(rz - cube.z);

    if (x_diff > y_diff && x_diff > z_diff){
        rx = -ry-rz;
    }
    else if (y_diff > z_diff) {
        ry = -rx-rz;
    } else{
        rz = -rx-ry;
    }

    return vec3(rx, ry, rz);
}

vec2 hex_round(vec2 hex){
    return cube_to_axial(cube_round(axial_to_cube(hex)));
}

vec2 cube_to_oddr(vec3 cube){
      float col = cube.x + (cube.z - mod(cube.z,2.)) / 2.;
      float row = cube.z;
      return vec2(col, row);
}

vec3 oddr_to_cube(vec2 hex){
      float x = hex.x - (hex.x - mod(hex.x,2.)) / 2.;
      float z = hex.y;
      float y = -x-z;
      return vec3(x, y, z);
}

vec2 hex_to_pixel(vec2 hex, float size){
    float x = size * sqrt(3.) * (hex.x + hex.y/2.);
    float y = size * 3./2. * hex.y;
    return vec2(x, y);
}

vec2 pixel_to_hex(vec2 p, float size){
    float x = p.x;
    float y = p.y;
    float q = (x * sqrt(3.)/3. - y / 3.) / size;
    float r = y * 2./3. / size;
    return vec2(q, r);
}

vec2 hexCenter2(vec2 p, float size){
    return hex_to_pixel(hex_round(pixel_to_hex(p, size)), size);
}

vec2 trans(vec2 u){
    return u*3.;
}

bool inSampleSet(vec2 p, vec2 center){
    float size = 1.;
    bool contained = false;
    for(float i = 0.; i < 6.; i++){
        float rad = PI / 8. + i * PI / 3.;
        vec2 corner = rotate(center, vec2(center.x+size, center.y), rad);
        for(float j = 0.; j < 3.; j++){
            vec2 samp = mix(center, corner, 1./(1.+j));
            contained = contained || distance(p, samp) < 0.05;
        }
    }
    return contained;
}

bool hexLumAvg(vec2 p, vec2 center){
    float size = 1.;
    bool contained = false;
    for(float i = 0.; i < 6.; i++){
        for(float j = 0.; j < 3.; j++){
            float rad = PI / 8. + i * PI / 3.;
            vec2 corner = rotate(center, vec2(center.x+size, center.y), rad);
            vec2 samp = mix(center, corner, 1./(1.+j));
            contained = contained || distance(p, samp) < 0.05;
        }
    }
    return contained;
}

void main(){

    // Aspect correct screen coordinates.
    vec2 u = trans(uv());
    
    float size = 1.;
    vec2 codec = hex_to_pixel(pixel_to_hex(u, size), size);
    vec2 hexV = pixel_to_hex(u, size);
    vec2 diffVec = u - codec;
    float diff = sqrt(dot(diffVec, diffVec));
    
    vec2 c = hexCenter2(u,size);
    float dist = distance(c, u);
    
    float sampled = inSampleSet(u, c) ? 1. : 0.;
    
    float radius = dist < .861 ? 1. : 0.;

    
    // Rough gamma correction.    
 gl_FragColor = vec4(vec3(dist, sampled, sampled), 1);
    
}