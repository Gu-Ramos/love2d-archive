extern vec2 direction;
vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc)
{
  vec4 c = 1.000000 * texture2D(tex, tc);
  c += 1.508854 * (texture2D(tex, tc + 7.500000 * direction) + texture2D(tex, tc - 7.500000 * direction));
  c += 1.717767 * (texture2D(tex, tc + 5.500000 * direction) + texture2D(tex, tc - 5.500000 * direction));
  c += 1.879114 * (texture2D(tex, tc + 3.500000 * direction) + texture2D(tex, tc - 3.500000 * direction));
  c += 1.975211 * (texture2D(tex, tc + 1.500000 * direction) + texture2D(tex, tc - 1.500000 * direction));
  return c * vec4(0.065955) * color;
}
