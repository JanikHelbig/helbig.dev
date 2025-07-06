#version 300 es

precision highp float;

#define MAX_COUNT 32
#define PI 3.1415926535897932384626433832795
#define TAU 2.0 * PI

uniform vec4 viewportRect;
uniform float time;
uniform vec2 mousePosition;

in vec2 texCoord;

out vec4 fragmentColor;

float dot2( vec2 v ) { return dot(v,v); }

float sdCircle( in vec2 p, in float r ) {
  return length(p) - r;
}

float sdBox( in vec2 p, in vec2 b ) {
  vec2 d = abs(p)-b;
  return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}

float sdEquilateralTriangle( in vec2 p, in float r )
{
    const float k = sqrt(3.0);
    p.x = abs(p.x) - r;
    p.y = p.y + r/k;
    if( p.x+k*p.y>0.0 ) p = vec2(p.x-k*p.y,-k*p.x-p.y)/2.0;
    p.x -= clamp( p.x, -2.0*r, 0.0 );
    return -length(p)*sign(p.y);
}

float sdRoundedX( in vec2 p, in float w, in float r )
{
    p = abs(p);
    return length(p-min(p.x+p.y,w)*0.5) - r;
}

float sdCross( in vec2 p, in vec2 b, float r )
{
    p = abs(p); p = (p.y>p.x) ? p.yx : p.xy;
    vec2  q = p - b;
    float k = max(q.y,q.x);
    vec2  w = (k>0.0) ? q : vec2(b.y-p.x,-k);
    return sign(k)*length(max(w,0.0)) + r;
}

float sdCoolS( in vec2 p )
{
    float six = (p.y<0.0) ? -p.x : p.x;
    p.x = abs(p.x);
    p.y = abs(p.y) - 0.2;
    float rex = p.x - min(round(p.x/0.4),0.4);
    float aby = abs(p.y-0.2)-0.6;

    float d = dot2(vec2(six,-p.y)-clamp(0.5*(six-p.y),0.0,0.2));
    d = min(d,dot2(vec2(p.x,-aby)-clamp(0.5*(p.x-aby),0.0,0.4)));
    d = min(d,dot2(vec2(rex,p.y  -clamp(p.y          ,0.0,0.4))));

    float s = 2.0*p.x + aby + abs(aby+0.4) - 0.4;
    return sqrt(d) * sign(s);
}

float sdHeart( in vec2 p )
{
    p.x = abs(p.x);

    if( p.y+p.x>1.0 )
    return sqrt(dot2(p-vec2(0.25,0.75))) - sqrt(2.0)/4.0;
    return sqrt(min(dot2(p-vec2(0.00,1.00)),
    dot2(p-0.5*max(p.x+p.y,0.0)))) * sign(p.x-p.y);
}

float opRound( in float d, in float r )
{
    return d - r;
}

float opOnion( in float d, in float r )
{
    return abs(d) - r;
}

// quadtratic polynomial
vec2 smin_quad( float a, float b, float k )
{
    float h = 1.0 - min( abs(a-b)/(4.0*k), 1.0 );
    float w = h*h;
    float m = w*0.5;
    float s = w*k;
    return (a<b) ? vec2(a-s,m) : vec2(b-s,1.0-m);
}

// cubic polynomial
vec2 smin_cubic( float a, float b, float k )
{
    float h = 1.0 - min( abs(a-b)/(6.0*k), 1.0 );
    float w = h*h*h;
    float m = w*0.5;
    float s = w*k; 
    return (a<b) ? vec2(a-s,m) : vec2(b-s,1.0-m);
}

float smoothstep_cubic_rational(float a, float b, float x)
{
    x = (x-a)/(b-a);
    return clamp(x*x*x/(3.0*x*x-3.0*x+1.0), 0.0, 1.0);
}

vec2 rotate(vec2 p, float theta) {
    return vec2( p.x * cos(theta) - p.y * sin(theta), p.x * sin(theta) + p.y * cos(theta) );
}

vec2 rotateAround(vec2 p, vec2 pivot, float theta) {
    p -= pivot;
    p = rotate(p, theta);
    return p + pivot;
}

float opSmoothSubtraction( float d1, float d2, float k )
{
    float h = clamp( 0.5 - 0.5*(d2+d1)/k, 0.0, 1.0 );
    return mix( d2, -d1, h ) + k*h*(1.0-h);
}

float antialiasedSDF(float sdf) {
    float fw = fwidth(sdf);
    return fw < 32.0 ? smoothstep(fw, -fw, sdf) : 0.0f;
}

//By Inigo Quilez, under MIT license
//https://www.shadertoy.com/view/ttcyRS
vec3 oklab_mix(vec3 lin1, vec3 lin2, float a)
{
    // https://bottosson.github.io/posts/oklab
    const mat3 kCONEtoLMS = mat3(
         0.4121656120,  0.2118591070,  0.0883097947,
         0.5362752080,  0.6807189584,  0.2818474174,
         0.0514575653,  0.1074065790,  0.6302613616);
    const mat3 kLMStoCONE = mat3(
         4.0767245293, -1.2681437731, -0.0041119885,
        -3.3072168827,  2.6093323231, -0.7034763098,
         0.2307590544, -0.3411344290,  1.7068625689);

    // rgb to cone (arg of pow can't be negative)
    vec3 lms1 = pow( kCONEtoLMS*lin1, vec3(1.0/3.0) );
    vec3 lms2 = pow( kCONEtoLMS*lin2, vec3(1.0/3.0) );
    // lerp
    vec3 lms = mix( lms1, lms2, a );
    // gain in the middle (no oklab anymore, but looks better?)
    lms *= 1.0+0.2*a*(1.0-a);
    // cone to rgb
    return kLMStoCONE*(lms*lms*lms);
}

bool isInBounds(vec2 position, vec2 boundsExtends, vec2 p) {
  vec2 pRelative = p - position;
  return all(greaterThanEqual(pRelative, -boundsExtends)) && all(lessThanEqual(pRelative, boundsExtends));
}

vec2 repeated( vec2 p, float s, out vec2 id ) {
    id = round(p/s);
    vec2 r = p - s*id;
    return r;
}

float sampleShape(vec2 p, int shapeIndex) {
    switch(shapeIndex % 5) {
        case 0: return sdBox(p, vec2(32, 32));
        case 1: return sdEquilateralTriangle(p, 48.0);
        case 2: return sdRoundedX(p, 48.0, 8.0);
        case 3: return sdHeart((p + vec2(0, 36.0)) / 56.0) * 56.0;
        case 4: return sdCoolS(p / 48.0) * 48.0 + 2.0;
        default: return sdCircle(p, 4.0);
    }
}

void main(void) {
    vec2 p = viewportRect.xy + viewportRect.zw * vec2(texCoord.x, 1.0 - texCoord.y);

    float d_mouse = sdCircle(p - mousePosition, 16.0);

    p -= viewportRect.xy + viewportRect.zw * 0.5;

    float scaledTime = time * 0.5;
    float t = smoothstep_cubic_rational(0.0, 1.0, fract(scaledTime));

    p = rotate(p, PI - t * TAU);

    int shapeIndex = int(floor(scaledTime));

    float d_shape_a = sampleShape(p, shapeIndex);
    float d_shape_b = sampleShape(p, shapeIndex + 1);
    float d_shape = mix(d_shape_a, d_shape_b, t);

    d_shape = opSmoothSubtraction(d_mouse, d_shape, 8.0);

    float d_shape_fill = d_shape - 1.0;
    float m_shape_fill = antialiasedSDF(d_shape_fill);
    vec4 c_shape_fill = vec4(1.0, 0, 0.25, 1.0) * m_shape_fill;

    float d_shape_outline = opOnion(d_shape - 2.0, 2.0);
    float m_shape_outline = antialiasedSDF(d_shape_outline);
    vec4 c_shape_outline = vec4(0.28, 0.29, 0.28, 1.0) * m_shape_outline; //  vec4(0.12, 0.10, 0.22, 1.0) * m_shape_outline;

    vec4 c_final = c_shape_fill;
    c_final = mix(c_final, c_shape_outline, c_shape_outline.a);

    fragmentColor = c_final;
}
