extern Image mask;
extern float cutoff;
vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    vec4 maskbw = Texel(mask, texture_coords);
    if (maskbw.r > cutoff) {
        discard;
    }
    vec4 texturecolor = Texel(tex, texture_coords);
    return texturecolor * color;
}