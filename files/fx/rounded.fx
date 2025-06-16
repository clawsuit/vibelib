// Parámetros de entrada
float4 sRectSizeAndRadius;  // x: ancho del rectángulo, y: altura del rectángulo, z: radio de los bordes redondeados

//------------------------------------------------------------------------------------------
// PixelShaderFunction
//  1. Lee de la estructura PS
//  2. Procesa
//  3. Devuelve el color del píxel
//------------------------------------------------------------------------------------------
float4 PixelShaderFunction(float4 Diffuse : COLOR0, float2 TexCoord : TEXCOORD0) : COLOR0
{
    // Calcula las coordenadas relativas al centro del rectángulo
    float2 p = abs(TexCoord.xy * sRectSizeAndRadius.xy - sRectSizeAndRadius.xy * 0.5);
    
    // Calcula la distancia al borde del rectángulo
    float2 dist = p - sRectSizeAndRadius.xy * 0.5 + sRectSizeAndRadius.z - 0.5;
    float d = min(max(dist.x, dist.y), 0.0);
    float isInside = step(d, 0.0);

    // Calcula la distancia al borde redondeado
    float2 roundedCorner = max(dist, 0.0);
    float roundedDist = length(roundedCorner);
    float isInsideRounded = step(roundedDist, sRectSizeAndRadius.z);

    // Combina los dos casos para formar el borde redondeado hacia dentro
    float4 color = lerp(Diffuse, float4(0, 0, 0, 0), isInside * (1.0 - isInsideRounded));

    return color;
}

//------------------------------------------------------------------------------------------
// Técnicas
//------------------------------------------------------------------------------------------
technique tec0
{
    pass P0
    {
        PixelShader = compile ps_2_0 PixelShaderFunction();
    }
}
