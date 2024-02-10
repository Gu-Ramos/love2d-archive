extern vec2 direction;
vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc)
{
  return color * vec4(texture2D(tex, tc - direction).r,
                      texture2D(tex, tc).g,
                      texture2D(tex, tc + direction).b,
                      1.0);
}
