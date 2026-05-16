#version 330 compatibility

uniform sampler2D colortex0;
uniform float frameTime;
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

uint uxor32(uint s)
{
    s = s ^ s << 13u;
    s = s ^ s >> 17u;
    s = s ^ s << 5u;

    return s;
}

float fxor32(uint s)
{
    return uintBitsToFloat(___ulog2_app(uxor32(s))) - 1.0;
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

    vec3 avg = vec3(0.0);
    float samples = 0.0;

    for(int x = 0; x < int(BIT_SIZE); x++)
        for(int y = 0; y < int(BIT_SIZE); y++)
        {
            vec2 uv = (blockCoord + vec2(x, y) + 0.5) / resolution;
            avg += texture(colortex0, uv).rgb;
            samples += 1.0;
        }

    avg /= samples;

    float noise = fxor32(initSeed(block));
    float l = luminance(avg) + (noise - 0.5) * 0.03;
    l = l * l * (3.0 - 2.0 * l);

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

    int bit = gglyphBit25(glyph, local);
    float density = float(bit);
    vec3 bg_color = avg * 0.08;
    vec3 fg_color = avg * 1.25;

    vec3 final = mix(bg_color, fg_color, density);

    color = vec4(clamp(final, 0.0, 1.0), 1.0);
}