#ifndef __BITS_GLSL_H
#define __BITS_GLSL_H 1

/* 25‑bit patterns for glyphs */
#define G_VOID_PATTERN 0x0000000u
#define G_DOLLAR_PATTERN 0x0eafaaeu
#define G_EIGHT_PATTERN 0x0e8ba2eu
#define G_PERCENT_PATTERN 0x1359359u
#define G_UNUSED_PATTERN 0x0000000u
#define G_BIG_O_PATTERN 0x0e8c62eu
#define G_SMALL_O_PATTERN 0x0d9c5c0u
#define G_ASTERISK_PATTERN 0x04abaa4u
#define G_COLON_PATTERN 0x020080u
#define G_DOT_PATTERN 0x400000u
#define G_QUESTION_PATTERN 0x0e89844u
#define G_HASH_PATTERN 0x0afabeau

#define SATURATE_F 1u << 25
#define COLOR_F 1u << 26

#define G_GLYPH_MASK 0x01FFFFFFu

#define FLAG(g) ((g) & ~G_GLYPH_MASK)
#define PURE(g) ((g) & G_GLYPH_MASK)

#define FSATURATE(f) ((f) & SATURATE_F)
#define FCOLOR(f) ((f) & COLOR_F)

#define ULOG2_APP(x) 0x3f800000u | ((x) >> 9u)

#endif