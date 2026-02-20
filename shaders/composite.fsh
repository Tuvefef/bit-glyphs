#version 330 compatibility

uniform sampler2D colortex0;
in vec2 atexcoord;

layout(location = 0) out vec4 color;

#define BIT_SIZE 7.0 //[4.0 4.5 5.0 5.5 6.0 6.5 7.0 7.5 8.0 8.5 9.0 9.5 10.0]

#include "common/bits.h"

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

void main()
{
    vec2 resolution = vec2(textureSize(colortex0, 0));
    vec2 apixel = atexcoord * resolution;

    vec2 block = floor(apixel / BIT_SIZE);
    vec2 blockCoord = block * BIT_SIZE;

    vec3 avg = vec3(0.0);

    for(int x = 0; x < 2; x++)
    for(int y = 0; y < 2; y++)
    {
        vec2 offset = vec2(x, y) / 2.0;
        vec2 uv = (blockCoord + offset * BIT_SIZE) / resolution;
        avg += texture(colortex0, uv).rgb;
    }

    avg /= 4.0;

    float l = luminance(avg);

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

    local = (local - 0.1) / 0.8;
    local = clamp(local, vec2(0.0), vec2(1.0));

    int bit = gglyphBit25(glyph, local);

    color = vec4(avg * float(bit), 1.0);
}