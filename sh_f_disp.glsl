#version 330

// Pixel Colors
#define B_GRD_COL vec3(0.00, 0.00, 0.00); // Black
#define BLOCK_COL vec3(0.48, 0.45, 0.43); // Gray
#define WATER_COL vec3(0.11, 0.79, 0.88); // Light-Blue
#define STONE_COL vec3(0.67, 0.67, 0.67); // Lighter Gray
#define STEAM_COL vec3(0.95, 0.95, 0.95); // Almost White
#define MAGMA_COL vec3(1.00, 0.27, 0.00); // Reddit Red (Orange?)
#define FIRE__COL vec3(0.90, 0.46, 0.06); // Brightspace Orange rgb(232,117,17)
#define DIRT__COL vec3(0.31, 0.17, 0.10); // rgb(79,44,26)
#define PLANT_COL vec3(0.30, 0.74, 0.45); // rgb(76,190,114)
#define ICE___COL vec3(0.75, 0.75, 0.90);

smooth in vec2 fragTC;		// Interpolated texture coordinates

uniform sampler2D tex;		// Texture sampler

out vec3 outCol;	// Final pixel color

// Output colors to the texture here
void main() {
	ivec2 texelCoord = ivec2(fragTC * textureSize(tex, 0));
	vec4 c = texelFetch(tex, texelCoord, 0);
	float type = c.x;


//	outCol = vec3(type / 2, 0, 0);


	if (type == 0) {
		outCol = B_GRD_COL;
	}
	if (type == 1000) {
		outCol = BLOCK_COL;
	}
	if (type == 0.5) {
		outCol = STEAM_COL;
	}
	if (type == 1) {
		outCol = WATER_COL;
	}
	if (type == 2) {
		outCol = MAGMA_COL;
	}
	if (type == 3) {
		outCol = STONE_COL;
	}
	if (type == 0.3) {
		outCol = FIRE__COL;
	}
	if (type == 1.5) {
		outCol = ICE___COL;
	}
	if (type == 1.25) {
		outCol = PLANT_COL;
	}
	if (type == 1.75) {
		outCol = DIRT__COL;
	}

	// outCol = texture(tex, fragTC).rgb;
}
