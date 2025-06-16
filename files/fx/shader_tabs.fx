// rounded_rect_outline.fx
float2 resolution;
float radius;
float smoothness;
float thickness = 2.0; // Grosor del borde (en píxeles)
float4 color = float4(1, 1, 1, 1); // Color del borde (RGBA)

float roundedBoxOutline(float2 uv, float2 size, float rad, float smooth, float thick)
{
    float2 halfSize = size * 0.5;
    float2 coord = uv * size;
    float2 dist = abs(coord - halfSize);
    float2 inner = halfSize - rad;

    float d = length(max(dist - inner, 0.0)) - rad;

    // Zona visible: un anillo entre [-thickness, 0], con suavizado
    float alphaOuter = 1.0 - smoothstep(0.0, smooth, d);
    float alphaInner = 1.0 - smoothstep(-thick, -thick + smooth, d);
    return saturate(alphaOuter - alphaInner); // solo borde
}

float4 main(float2 uv : TEXCOORD0) : COLOR0
{
    float alpha = roundedBoxOutline(uv, resolution, radius, smoothness, thickness);
    return float4(color.rgb, color.a * alpha);
}

technique Draw
{
    pass P0
    {
        PixelShader = compile ps_2_0 main();
    }
}
