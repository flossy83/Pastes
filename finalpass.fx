#include "common.fxh"
#include "postprocessing.fxh"

#if(CLASSIC_LIGHTING==1)
#define GAMMA_SCALE 1
#else
#define GAMMA_SCALE 0.8 //.8 so we do nothing at brightness 0.5.
#endif

cbuffer finalConstants
{
	float brightness;
}

PS_OUTPUT_SIMPLE PS_final(PS_INPUT_SIMPLE input)
{
	PS_OUTPUT_SIMPLE output = (PS_OUTPUT_SIMPLE)0;
				
	int3 coords = int3(input.pos.xy,0);		
	output.color=inputTexture.Load(coords);

	// Apply the in-game brightness setting so that its default (0.5)
	// results in gamma=(1.0/1.3) - supposedly the value which video
	// cards of that era were set to by default
	output.color.rgb=pow(abs(output.color.rgb),1.0f/(brightness+0.8f));

	// Subpixel dithering to prevent gradient banding	
	float seed = dot(input.pos.xy, float2(12.9898f,78.233f));
	float noise = frac(frac(sin(seed)) * 43758.5453f);
	float ditherStrength = 1.0f / 256.0f;	
	noise = (noise * ditherStrength) - (ditherStrength * 0.5f);	
	if ((output.color.r != 0) && (output.color.r != 1)) 
		output.color.r += -noise;
	if ((output.color.g != 0) && (output.color.g != 1))
		output.color.g += noise;
	if ((output.color.b != 0) && (output.color.b != 1))
		output.color.b += -noise;
	
	return output;
	

}

technique10 Render
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS_identity() ) );	
		SetGeometryShader( 0 );
		SetPixelShader( CompileShader( ps_4_0, PS_final() ) );
		SetRasterizerState(rstate_NoMSAA);    	
	}
}
