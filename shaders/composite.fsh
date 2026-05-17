#version 330 compatibility

uniform sampler2D colortex0;
uniform float frameTime;
in vec2 atexcoord;

layout(location = 0) out vec4 color;

#include "bits/bits.h"
#include "inc/inc.glsl"

float luminance(vec3 c) 
{
    return dot(c, vec3(0.299, 0.587, 0.114));
}

int gglyphBit25(uint ub, vec2 c)
{
    ivec2 ic = ivec2(floor(c * 5.0));

    if (any(lessThan(ic, ivec2(0))) || any(greaterThan(ic, ivec2(4))))
        return 0;

    int ii = ic.x + 5 * ic.y;
    uint us = ub >> uint(ii);

    return int(us & 1u);
}

uint uxor32(uint s)
{
    s = s ^ s << 13u;
    s = s ^ s >> 17u;
    s = s ^ s << 5u;

    return s;
}

float fxor32(uint s)
{
    return uintBitsToFloat(ULOG2_APP(uxor32(s))) - 1.0;
}

uint initSeed(vec2 coord)
{
    return uint(coord.x) * 0x0019660du 
        + uint(coord.y) * 0x3c6ef35fu;
}

void main()
{
    vec2 resolution = vec2(textureSize(colortex0, 0));
    vec2 apixel = atexcoord * resolution;

    vec2 block = floor(apixel / BIT_SIZE);
    vec2 blockCoord = block * BIT_SIZE;

    float mipLevel = log2(BIT_SIZE);
    vec3 avg = textureLod(colortex0, blockCoord / resolution + 0.5 / resolution, mipLevel).rgb;

    float noise = fxor32(initSeed(block));
    float l = luminance(avg) + (noise - 0.5) * 0.03;
#ifdef SMOOTH_LUMA
    l = l * l * (3.0 - 2.0 * l);
#endif

    uint glyph = G_VOID_PATTERN;

    if      (l > 0.90) glyph = G_HASH_PATTERN;
    else if (l > 0.75) glyph = G_EIGHT_PATTERN;
    else if (l > 0.60) glyph = G_BIG_O_PATTERN;
    else if (l > 0.45) glyph = G_SMALL_O_PATTERN; 
    else if (l > 0.30) glyph = G_QUESTION_PATTERN;
    else if (l > 0.18) glyph = G_ASTERISK_PATTERN;
    else if (l > 0.08) glyph = G_COLON_PATTERN;
    else if (l > 0.05) glyph = G_DOT_PATTERN;

    vec2 local = mod(apixel, BIT_SIZE) / BIT_SIZE;
    float padding = 1.0 / BIT_SIZE;
    local = (local - padding) / (1.0 - 2.0 * padding);
    local = clamp(local, vec2(0.0), vec2(1.0));

    uint flag = FLAG(glyph);
    uint pure = PURE(glyph);

    int bit = gglyphBit25(pure, local);

#ifdef SATURATE
    flag |= SATURATE_F;
#endif
#ifdef CUSTOM_COLOR
    flag |= COLOR_F;
#endif

    vec3 setColor = avg;
    if (FSATURATE(flag) != 0u)
    {
        vec3 gray = vec3(luminance(avg));
        setColor = mix(gray, avg, 1.4);
    }

    if (FCOLOR(flag) != 0u)
    {
        setColor = vec3(RED, GREEN, BLUE);
    }

    float density = float(bit);
    vec3 bgColor = avg * 0.08;

    vec3 fgColor = clamp(setColor * 1.3, 0.0, 1.0);

    vec3 final = mix(bgColor, fgColor, density);

    color = vec4(clamp(final, 0.0, 1.0), 1.0);
}