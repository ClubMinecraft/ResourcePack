// in a resource pack, this file goes in assets/minecraft/shaders/core

#version 150

#moj_import <fog.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;

uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform int FogShape;

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    vertexDistance = fog_distance(Position, FogShape);
    vertexColor = Color * texelFetch(Sampler2, UV2 / 16, 0); // by default, this takes the color of the font provider (the texelFetch) and adds the overlay color ("Color")
    texCoord0 = UV0;
	
	// ----- everything above this is the whole vanilla shader, everything below this is added -----
	
	// how it works: choose a text overlay color that you'll never use (i used total yellow, R255 G255 B0 or #FFFF00)
	// any text overlayed with that color will display without a shadow using the below two lines of code
	// (minecraft's built-in yellow is more pale than this so it'll still have a shadow)
	// note: a png used in a font can still have #FFFF00 in it and will not affect the text shadow, we're only looking at the overlay colors
	
	// first: if the text is overlayed with our selected color, override vertexColor to ignore the "Color" parameter (the overlay color)
	//        this is so that the text doesn't actually show up yellow
	//        IMPORTANT: the colors aren't quite exact so we check for a color *very close* to #FFFF00
	if (Color.r > 250/255. && Color.g > 250/255. && Color.b < 5/255.) vertexColor = texelFetch(Sampler2, UV2 / 16, 0);
	
	// second: if the overlay color is this specific darkened yellow then it's a shadow of the above color -
	//         set the vertexColor to zero including the alpha value so it'll be invisible
	//         i just had to identify this specific color through a bit of trial and error (60-65 red and green, 0-5 blue)
	else if (Color.r > 60/255. && Color.r < 65/255. && Color.g > 60/255. && Color.g < 65/255. && Color.b < 5/255.) vertexColor = vec4(0);
	
}