shader_type canvas_item;

uniform float radius = .2;
//uniform float width = .2;
uniform float border_thickness = .2;
uniform vec4 border_color : source_color = vec4(1.0, .2, .2, 1.0);
uniform vec4 color : source_color = vec4(1.0, .6, .6, 1.0);

float RectSDF(vec2 p, vec2 b, float r)
{
    vec2 d = abs(p) - b + vec2(r);
    return min(max(d.x, d.y), 0.0) + length(max(d, 0.0)) - r;   
}

void fragment()
{
//	float len = RectSDF(UV-vec2(.5,.5), vec2(.45,.45), radius);
//	if (len > border_thickness) discard;
//	else COLOR = len < 0.0 ? color : border_color;
	
	
	vec2 uv = abs(2.0*(UV - vec2(.5,.5)));
	if (uv.y > uv.x) uv = uv.yx;
	float inner_w = 1.0 - radius;
	if (uv.y < inner_w)
	{
		COLOR = uv.x < 1.0 - border_thickness ? color : border_color;
	}
	else {
		float l = length(uv - vec2(inner_w, inner_w));
		if (l < radius - border_thickness) COLOR = color;
		else if (l < radius) COLOR = border_color;
		else discard;
	}
}
