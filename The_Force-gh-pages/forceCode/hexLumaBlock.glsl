/*


    Minimal Hexagonal Grid
    ----------------------

    This is not exactly a cutting edge example, but I'd almost say getting comfortable
    with a hexagonal grid is mandatory when it comes to creating interesting patterns.
    Therefore, I've put this up - as an additional alternative to the other beginner 
    references - for anyone who wants to get a start.
    
    In regard to tesselating a grid with a single regular polygon, you have a choice 
    between a triangle, a square or a hexagon (unless I'm overlooking one). The hexagon 
    has the most sides, which means it provides the most interesting combinations. A
    great example of this would be BigWings's "Hexagonal Truchet Weaving" shader.

    There are a few different methods used to construct a hexagonal grid. Everyone
    has their preference, but I like to obtain the nearest hexagon center with the least
    amount of effort (fewest operations), then render a 2D isosurface around it.

    If the 2D surface happens to be a hexagon, the return value will represent the 
    nearest edge distance - since isosurfaces give boundary distances by design. 
    Rendering a circle around the cell center will be analogous to a Euclidian hexagon 
    center distance.

    It's also trivial to take the nearest hexagonal center point to produce a relative 
    position for the cell and a unique hexagonal grid cell ID.

    Anyway, I've explained the process in more detail below. It's one of those things 
    that is easy to perform, but less easy to explain. However, I believe the code 
    should make it more clear.

    By the way, if anyone spots any errors, or knows of ways to improve the operation 
    count in the "getHex" function, then feel free to let me know.

    Related references:
    
    // Uses the same principle. I stuck with my own code (adapted from my "Hexagonal 
    // Blocks" example), but I liked the simpler way Iomateron compared distances, so 
    // I've adopted that portion of his code.
    Iomateron - simple hexagonal tiles
    https://www.shadertoy.com/view/MlXyDl

    // You can't do a hexagonal grid example without referencing this. :) Very stylish.
    Hexagons - distance - iq
    https://www.shadertoy.com/view/Xd2GR3

*/

// Helper vector. If you're doing anything that involves regular triangles or hexagons, the
// 30-60-90 triangle will be involved in some way, which has sides of 1, sqrt(3) and 2.
const vec2 s = vec2(1, 1.7320508);

// Standard vec2 to float hash - Based on IQ's original.
float hash21(vec2 p){ return fract(sin(dot(p, vec2(141.13, 289.97)))*43758.5453); }


// The 2D hexagonal isosuface function: If you were to render a horizontal line and one that
// slopes at 60 degrees, mirror, then combine them, you'd arrive at the following. As an aside,
// the function may be a bound - as opposed to a Euclidean distance representation, but either
// way, the result is hexagonal boundary lines.
float hex(in vec2 p){
    
    p = abs(p);
    
    // Below is equivalent to:
    //return max(p.x*.5 + p.y*.866025, p.x); 

    return max(dot(p, s*.5), p.x); // Hexagon.
    
}

vec2 hexCenter(vec2 pt){
    vec4 hC = floor(vec4(pt, pt - vec2(.5, 1.))/s.xyxy) + .5;
    return dot(hC.xy, pt) < dot(hC.zw, pt) ? hC.xy : hC.zw;
}

// This function returns the hexagonal grid coordinate for the grid cell, and the corresponding 
// hexagon cell ID - in the form of the central hexagonal point. That's basically all you need to 
// produce a hexagonal grid.
//
// When working with 2D, I guess it's not that important to streamline this particular function.
// However, if you need to raymarch a hexagonal grid, the number of operations tend to matter.
// This one has minimal setup, one "floor" call, a couple of "dot" calls, a ternary operator, etc.
// To use it to raymarch, you'd have to double up on everything - in order to deal with 
// overlapping fields from neighboring cells, so the fewer operations the better.
vec4 getHex(vec2 p){
    
    // The hexagon centers: Two sets of repeat hexagons are required to fill in the space, and
    // the two sets are stored in a "vec4" in order to group some calculations together. The hexagon
    // center we'll eventually use will depend upon which is closest to the current point. Since 
    // the central hexagon point is unique, it doubles as the unique hexagon ID.
    vec4 hC = floor(vec4(p, p - vec2(.5, 1.))/s.xyxy) + .5;
    
    // Centering the coordinates with the hexagon centers above.
    vec4 h = vec4(p - hC.xy*s, p - (hC.zw + .5)*s);
    
    // Nearest hexagon center (with respect to p) to the current point. In other words, when
    // "h.xy" is zero, we're at the center. We're also returning the corresponding hexagon ID -
    // in the form of the hexagonal central point. Note that a random constant has been added to 
    // "hC.zw" to further distinguish it from "hC.xy."
    //
    // On a side note, I sometimes compare hex distances, but I noticed that Iomateron compared
    // the squared Euclidian version, which seems neater, so I've adopted that.
    return dot(h.xy, h.xy)<dot(h.zw, h.zw) ? vec4(h.xy, hC.xy) : vec4(h.zw, hC.zw + 9.73);
    
}

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
    float y = size * 3./2. * hex.r;
    return vec2(x, y);
}

vec2 pixel_to_hex(float x, float y, float size){
    float q = (x * sqrt(3.)/3. - y / 3.) / size;
    float r = y * 2./3. / size;
    return vec2(q, r);
}

vec2 pixel_to_hex(vec2 p, float size){
    float x = p.x;
    float y = p.y;
    float q = (x * sqrt(3.)/3. - y / 3.) / size;
    float r = y * 2./3. / size;
    return vec2(q, r);
}

vec2 hexCenter2(vec2 p, float size){
    return hex_to_pixel(hex_round(pixel_to_hex(p.x, p.y, size)), size);
}

vec2 trans(vec2 u){
    return u*1.;
}

void main(){

    // Aspect correct screen coordinates.
    vec2 u = trans(uv()*4.);
    
    // Scaling, translating, then converting it to a hexagonal grid cell coordinate and
    // a unique coordinate ID. The resultant vector contains everything you need to produce a
    // pretty pattern, so what you do from here is up to you.
    vec4 h = getHex(u);
    
    // The beauty of working with hexagonal centers is that the relative edge distance will simply 
    // be the value of the 2D isofield for a hexagon.
    //
    
    float size = 10.;
    vec2 diffVec = u- hex_to_pixel(pixel_to_hex(u, size), size);
    float diff = sqrt(dot(diffVec, diffVec));
    
    vec2 c = hexCenter2(u, 1.);
    
    float eDist = hex(h.xy); // Edge distance.
    float cDist = sqrt(dot(h.xy, h.xy)); // Relative squared distance from the center.
    // float radius = eDist > 0.49 ? 1. : 0.;
    float radius = sqrt(dot(u.xy, c.xy)) == 0. ? 1. : 0.;

    
    // Using the idetifying coordinate - stored in "h.zw," to produce a unique random number
    // for the hexagonal grid cell.
    float rnd = hash21(h.zw);
    rnd = sin(rnd*6.283 + time*1.5)*.5 + .5; // Animating the random number.
    
    // It's possible to control the randomness to form some kind of repeat pattern.
    //rnd = mod(h.z + h.w, 4.)/3.;
    
    
    
    // Rough gamma correction.    
 gl_FragColor = vec4(vec3(diff), 1);
    
}