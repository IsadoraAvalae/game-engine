module zyeware.rendering.color;

import std.conv : to;
import std.exception : enforce;
import std.string : format, toLower;

import inmath.linalg;
import inmath.hsv : rgb2hsv, hsv2rgb;

import zyeware;

alias Gradient = Interpolator!(color, color.lerp);

/// 4-dimensional vector representing a color (rgba).
struct color
{
public:
    vec4 vec;
    alias vec this;

    this(string name) pure
    {
        enforce!GraphicsException(name && name.length > 0, "Invalid color name or hexcode.");

        if (name[0] == '#')
        {
            name = name[1 .. $];

            enforce!GraphicsException(name.length >= 6, format!"Invalid color hexcode '%s'."(name));

            vec.r = name[0..2].to!ubyte(16) / 255.0;
            vec.g = name[2..4].to!ubyte(16) / 255.0;
            vec.b = name[4..6].to!ubyte(16) / 255.0;
            vec.a = name.length > 6 ? name[6..8].to!ubyte(16) / 255.0 : 1.0;
        }
        else
        {
        outer:
            switch (name.toLower)
            {
                static foreach (data; predefinedColors)
                {
                    mixin(format!"case \"%s\": vec = vec4(%f, %f, %f, 1.0); break outer;"(data.name, data.rgb.x, data.rgb.y, data.rgb.z));
                }

            default:
                throw new GraphicsException(format!"Invalid color name '%s'."(name));
            }
        }
    }

    this(float r, float g, float b, float a = 1f) @safe pure nothrow @nogc
    {
        vec = vec4(r, g, b, a);
    }

    this(vec4 values) @safe pure nothrow @nogc
    {
        vec = values;
    }

    pragma(inline, true)
    color toRgb() const nothrow
    {
        return color(hsv2rgb(vec4(vec.x / 360.0f, vec.y, vec.z, vec.w)));
    }

    pragma(inline, true)
    color toHsv() pure const nothrow
    {
        return color(rgb2hsv(vec));
    }

    pragma(inline, true)
    color brighten(float amount) pure const nothrow @nogc
    {
        return color(vec.r + amount, vec.g + amount, vec.b + amount, vec.a);
    }

    pragma(inline, true)
    color darken(float amount) pure const nothrow @nogc
    {
        return brighten(-amount);
    }

    static color lerp(color a, color b, float t) pure nothrow
    {
        immutable vec4 result = zyeware.core.math.numeric.lerp(a.vec, b.vec, t);
        return color(result.r, result.g, result.b, result.a);
    }
}

@("Color")
unittest
{
    import unit_threaded.assertions;

    // Create a color from a hex code
    color c1 = color("#FF0000");
    shouldEqual(c1.vec, vec4(1.0f, 0.0f, 0.0f, 1.0f));

    // Create a color from RGB values
    color c2 = color(0.0f, 1.0f, 0.0f);
    shouldEqual(c2.vec, vec4(0.0f, 1.0f, 0.0f, 1.0f));

    // Create a color from a vec4
    vec4 v = vec4(0.0f, 0.0f, 1.0f, 1.0f);
    color c3 = color(v);
    shouldEqual(c3.vec, v);

    // Convert to HSV
    color c5 = c3.toHsv();
    shouldEqual(c5.vec, vec4(240.0f, 1.0f, 1.0f, 1.0f));

    // Convert to RGB
    color c4 = c5.toRgb();
    shouldEqual(c4.vec, vec4(0.0f, 0.0f, 1.0f, 1.0f));

    // Brighten
    color c6 = c2.brighten(0.5f);
    shouldEqual(c6.vec, vec4(0.5f, 1.5f, 0.5f, 1.0f));

    // Darken
    color c7 = c2.darken(0.5f);
    shouldEqual(c7.vec, vec4(-0.5f, 0.5f, -0.5f, 1.0f));

    // Lerp
    color c8 = color.lerp(c1, c2, 0.5f);
    shouldEqual(c8.vec, vec4(0.5f, 0.5f, 0.0f, 1.0f));
}

private:

import std.typecons : Tuple;

alias NamedColor = Tuple!(string, "name", vec3, "rgb");

// Many thanks to the Godot engine for providing these values!
enum predefinedColors = [
    NamedColor("aliceblue", vec3(0.94, 0.97, 1)),
    NamedColor("antiquewhite", vec3(0.98, 0.92, 0.84)),
    NamedColor("aqua", vec3(0, 1, 1)),
    NamedColor("aquamarine", vec3(0.5, 1, 0.83)),
    NamedColor("azure", vec3(0.94, 1, 1)),
    NamedColor("beige", vec3(0.96, 0.96, 0.86)),
    NamedColor("bisque", vec3(1, 0.89, 0.77)),
    NamedColor("black", vec3(0, 0, 0)),
    NamedColor("blanchedalmond", vec3(1, 0.92, 0.8)),
    NamedColor("blue", vec3(0, 0, 1)),
    NamedColor("blueviolet", vec3(0.54, 0.17, 0.89)),
    NamedColor("brown", vec3(0.65, 0.16, 0.16)),
    NamedColor("burlywood", vec3(0.87, 0.72, 0.53)),
    NamedColor("cadetblue", vec3(0.37, 0.62, 0.63)),
    NamedColor("chartreuse", vec3(0.5, 1, 0)),
    NamedColor("chocolate", vec3(0.82, 0.41, 0.12)),
    NamedColor("coral", vec3(1, 0.5, 0.31)),
    NamedColor("cornflower", vec3(0.39, 0.58, 0.93)),
    NamedColor("cornsilk", vec3(1, 0.97, 0.86)),
    NamedColor("crimson", vec3(0.86, 0.08, 0.24)),
    NamedColor("cyan", vec3(0, 1, 1)),
    NamedColor("darkblue", vec3(0, 0, 0.55)),
    NamedColor("darkcyan", vec3(0, 0.55, 0.55)),
    NamedColor("darkgoldenrod", vec3(0.72, 0.53, 0.04)),
    NamedColor("darkgray", vec3(0.66, 0.66, 0.66)),
    NamedColor("darkgreen", vec3(0, 0.39, 0)),
    NamedColor("darkkhaki", vec3(0.74, 0.72, 0.42)),
    NamedColor("darkmagenta", vec3(0.55, 0, 0.55)),
    NamedColor("darkolivegreen", vec3(0.33, 0.42, 0.18)),
    NamedColor("darkorange", vec3(1, 0.55, 0)),
    NamedColor("darkorchid", vec3(0.6, 0.2, 0.8)),
    NamedColor("darkred", vec3(0.55, 0, 0)),
    NamedColor("darksalmon", vec3(0.91, 0.59, 0.48)),
    NamedColor("darkseagreen", vec3(0.56, 0.74, 0.56)),
    NamedColor("darkslateblue", vec3(0.28, 0.24, 0.55)),
    NamedColor("darkslategray", vec3(0.18, 0.31, 0.31)),
    NamedColor("darkturquoise", vec3(0, 0.81, 0.82)),
    NamedColor("darkviolet", vec3(0.58, 0, 0.83)),
    NamedColor("deeppink", vec3(1, 0.08, 0.58)),
    NamedColor("deepskyblue", vec3(0, 0.75, 1)),
    NamedColor("dimgray", vec3(0.41, 0.41, 0.41)),
    NamedColor("dodgerblue", vec3(0.12, 0.56, 1)),
    NamedColor("firebrick", vec3(0.7, 0.13, 0.13)),
    NamedColor("floralwhite", vec3(1, 0.98, 0.94)),
    NamedColor("forestgreen", vec3(0.13, 0.55, 0.13)),
    NamedColor("fuchsia", vec3(1, 0, 1)),
    NamedColor("gainsboro", vec3(0.86, 0.86, 0.86)),
    NamedColor("ghostwhite", vec3(0.97, 0.97, 1)),
    NamedColor("gold", vec3(1, 0.84, 0)),
    NamedColor("goldenrod", vec3(0.85, 0.65, 0.13)),
    NamedColor("gray", vec3(0.75, 0.75, 0.75)),
    NamedColor("green", vec3(0, 1, 0)),
    NamedColor("greenyellow", vec3(0.68, 1, 0.18)),
    NamedColor("honeydew", vec3(0.94, 1, 0.94)),
    NamedColor("hotpink", vec3(1, 0.41, 0.71)),
    NamedColor("indianred", vec3(0.8, 0.36, 0.36)),
    NamedColor("indigo", vec3(0.29, 0, 0.51)),
    NamedColor("ivory", vec3(1, 1, 0.94)),
    NamedColor("khaki", vec3(0.94, 0.9, 0.55)),
    NamedColor("lavender", vec3(0.9, 0.9, 0.98)),
    NamedColor("lavenderblush", vec3(1, 0.94, 0.96)),
    NamedColor("lawngreen", vec3(0.49, 0.99, 0)),
    NamedColor("lemonchiffon", vec3(1, 0.98, 0.8)),
    NamedColor("lightblue", vec3(0.68, 0.85, 0.9)),
    NamedColor("lightcoral", vec3(0.94, 0.5, 0.5)),
    NamedColor("lightcyan", vec3(0.88, 1, 1)),
    NamedColor("lightgoldenrod", vec3(0.98, 0.98, 0.82)),
    NamedColor("lightgray", vec3(0.83, 0.83, 0.83)),
    NamedColor("lightgreen", vec3(0.56, 0.93, 0.56)),
    NamedColor("lightpink", vec3(1, 0.71, 0.76)),
    NamedColor("lightsalmon", vec3(1, 0.63, 0.48)),
    NamedColor("lightseagreen", vec3(0.13, 0.7, 0.67)),
    NamedColor("lightskyblue", vec3(0.53, 0.81, 0.98)),
    NamedColor("lightslategray", vec3(0.47, 0.53, 0.6)),
    NamedColor("lightsteelblue", vec3(0.69, 0.77, 0.87)),
    NamedColor("lightyellow", vec3(1, 1, 0.88)),
    NamedColor("lime", vec3(0, 1, 0)),
    NamedColor("limegreen", vec3(0.2, 0.8, 0.2)),
    NamedColor("linen", vec3(0.98, 0.94, 0.9)),
    NamedColor("magenta", vec3(1, 0, 1)),
    NamedColor("maroon", vec3(0.69, 0.19, 0.38)),
    NamedColor("mediumaquamarine", vec3(0.4, 0.8, 0.67)),
    NamedColor("mediumblue", vec3(0, 0, 0.8)),
    NamedColor("mediumorchid", vec3(0.73, 0.33, 0.83)),
    NamedColor("mediumpurple", vec3(0.58, 0.44, 0.86)),
    NamedColor("mediumseagreen", vec3(0.24, 0.7, 0.44)),
    NamedColor("mediumslateblue", vec3(0.48, 0.41, 0.93)),
    NamedColor("mediumspringgreen", vec3(0, 0.98, 0.6)),
    NamedColor("mediumturquoise", vec3(0.28, 0.82, 0.8)),
    NamedColor("mediumvioletred", vec3(0.78, 0.08, 0.52)),
    NamedColor("midnightblue", vec3(0.1, 0.1, 0.44)),
    NamedColor("mintcream", vec3(0.96, 1, 0.98)),
    NamedColor("mistyrose", vec3(1, 0.89, 0.88)),
    NamedColor("moccasin", vec3(1, 0.89, 0.71)),
    NamedColor("navajowhite", vec3(1, 0.87, 0.68)),
    NamedColor("navyblue", vec3(0, 0, 0.5)),
    NamedColor("oldlace", vec3(0.99, 0.96, 0.9)),
    NamedColor("olive", vec3(0.5, 0.5, 0)),
    NamedColor("olivedrab", vec3(0.42, 0.56, 0.14)),
    NamedColor("orange", vec3(1, 0.65, 0)),
    NamedColor("orangered", vec3(1, 0.27, 0)),
    NamedColor("orchid", vec3(0.85, 0.44, 0.84)),
    NamedColor("palegoldenrod", vec3(0.93, 0.91, 0.67)),
    NamedColor("palegreen", vec3(0.6, 0.98, 0.6)),
    NamedColor("paleturquoise", vec3(0.69, 0.93, 0.93)),
    NamedColor("palevioletred", vec3(0.86, 0.44, 0.58)),
    NamedColor("papayawhip", vec3(1, 0.94, 0.84)),
    NamedColor("peachpuff", vec3(1, 0.85, 0.73)),
    NamedColor("peru", vec3(0.8, 0.52, 0.25)),
    NamedColor("pink", vec3(1, 0.75, 0.8)),
    NamedColor("plum", vec3(0.87, 0.63, 0.87)),
    NamedColor("powderblue", vec3(0.69, 0.88, 0.9)),
    NamedColor("purple", vec3(0.63, 0.13, 0.94)),
    NamedColor("rebeccapurple", vec3(0.4, 0.2, 0.6)),
    NamedColor("red", vec3(1, 0, 0)),
    NamedColor("rosybrown", vec3(0.74, 0.56, 0.56)),
    NamedColor("royalblue", vec3(0.25, 0.41, 0.88)),
    NamedColor("saddlebrown", vec3(0.55, 0.27, 0.07)),
    NamedColor("salmon", vec3(0.98, 0.5, 0.45)),
    NamedColor("sandybrown", vec3(0.96, 0.64, 0.38)),
    NamedColor("seagreen", vec3(0.18, 0.55, 0.34)),
    NamedColor("seashell", vec3(1, 0.96, 0.93)),
    NamedColor("sienna", vec3(0.63, 0.32, 0.18)),
    NamedColor("silver", vec3(0.75, 0.75, 0.75)),
    NamedColor("skyblue", vec3(0.53, 0.81, 0.92)),
    NamedColor("slateblue", vec3(0.42, 0.35, 0.8)),
    NamedColor("slategray", vec3(0.44, 0.5, 0.56)),
    NamedColor("snow", vec3(1, 0.98, 0.98)),
    NamedColor("springgreen", vec3(0, 1, 0.5)),
    NamedColor("steelblue", vec3(0.27, 0.51, 0.71)),
    NamedColor("tan", vec3(0.82, 0.71, 0.55)),
    NamedColor("teal", vec3(0, 0.5, 0.5)),
    NamedColor("thistle", vec3(0.85, 0.75, 0.85)),
    NamedColor("tomato", vec3(1, 0.39, 0.28)),
    NamedColor("turquoise", vec3(0.25, 0.88, 0.82)),
    NamedColor("violet", vec3(0.93, 0.51, 0.93)),
    NamedColor("webgray", vec3(0.5, 0.5, 0.5)),
    NamedColor("webgreen", vec3(0, 0.5, 0)),
    NamedColor("webmaroon", vec3(0.5, 0, 0)),
    NamedColor("webpurple", vec3(0.5, 0, 0.5)),
    NamedColor("wheat", vec3(0.96, 0.87, 0.7)),
    NamedColor("white", vec3(1, 1, 1)),
    NamedColor("whitesmoke", vec3(0.96, 0.96, 0.96)),
    NamedColor("yellow", vec3(1, 1, 0)),
    NamedColor("yellowgreen", vec3(0.6, 0.8, 0.2)),
    NamedColor("grape", vec3(111/255.0, 45/255.0, 168/255.0))
];