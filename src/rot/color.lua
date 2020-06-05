--- The Color Toolkit.
-- Color is a color handler that treats any
-- objects intended to represent a color as a
-- table of the following schema:
-- @module ROT.Color

local ROT = require((...):gsub(('.[^./\\]*'):rep(1) .. '$', ''))
local Color = ROT.Class:extend("Color")

function Color:init(r, g, b, a)
    self[1], self[2], self[3], self[4] = r or 0, g or 0, b or 0, a
end

--- Get color from string.
-- Convert one of several formats of string to what
-- Color interperets as a color object
-- @tparam string str Accepted formats 'rgb(0..255, 0..255, 0..255)', '#5fe', '#5FE', '#254eff', 'goldenrod'
function Color.fromString(str)
    local cached = Color._cached[str]
    if cached then return cached end
    local values = { 0.0, 0.0, 0.0 }
    if str:sub(1,1) == '#' then
        local i = 1
        for s in str:gmatch('[%da-fA-F]') do
            values[i] = tonumber(s, 16)
            i = i + 1
        end
        if #values == 3 then
            for i = 1,3 do 
				values[i]=(values[i]*17)/255.0 

			end
		else
			for i = 1, 3 do
				values[i+1] = (values[i+1]+(16*values[i]))/255.0
				table.remove(values, i)
			end
		end
	end
    Color._cached[str] = values
    return values
end

local function add(t, color, ...)
    if not color then return t end
    for i = 1, #color do
        t[i] = (t[i] or 0) + color[i]
    end
    return add(t, ...)
end

local function multiply(t, color, ...)
    if not color then return t end
    for i = 1, #color do
        t[i] = (t[i] or 1) * color[i]
    end
    return multiply(t, ...)
end

--- Add two or more colors.
-- @tparam table color1 A color table
-- @tparam table color2 A color table
-- @tparam table ... More color tables
-- @treturn table new color
function Color.add(...) return add({}, ...) end

--- Add two or more colors. Modifies first color in-place.
-- @tparam table color1 A color table
-- @tparam table color2 A color table
-- @tparam table ... More color tables
-- @treturn table modified color
function Color.add_(...) return add(...) end

-- Multiply (mix) two or more colors.
-- @tparam table color1 A color table
-- @tparam table color2 A color table
-- @tparam table ... More color tables
-- @treturn table new color
function Color.multiply(...) return multiply({}, ...) end

-- Multiply (mix) two or more colors. Modifies first color in-place.
-- @tparam table color1 A color table
-- @tparam table color2 A color table
-- @tparam table ... More color tables
-- @treturn table modified color
function Color.multiply_(...) return multiply(...) end

--- Interpolate (blend) two colors with a given factor.
-- @tparam table color1 A color table
-- @tparam table color2 A color table
-- @tparam float factor A number from 0 to 1. <0.5 favors color1, >0.5 favors color2.
-- @treturn table resulting color
function Color.interpolate(color1, color2, factor)
    factor = factor or .5
    local result = {}
    for i = 1, math.max(#color1, #color2) do
        local a, b = color2[i] or color1[i], color1[i] or color2[i]
        result[i] = math.floor(b + factor*(a-b) + 0.5)
    end
    return result
end

--- Interpolate (blend) two colors with a given factor in HSL mode.
-- @tparam table color1 A color table
-- @tparam table color2 A color table
-- @tparam float factor A number from 0 to 1. <0.5 favors color1, >0.5 favors color2.
-- @treturn table resulting color
function Color.interpolateHSL(color1, color2, factor)
    factor = factor or .5
    local result = {}
    local hsl1, hsl2 = Color.rgb2hsl(color1), Color.rgb2hsl(color2)
    for i = 1, math.max(#hsl1, #hsl2) do
        local a, b = hsl2[i] or hsl1[i], hsl1[i] or hsl2[i]
        result[i] = b + factor*(a-b)
    end
    return Color.hsl2rgb(result)
end

--- Create a new random color based on this one
-- @tparam table color A color table
-- @tparam int|table diff One or more numbers to use for a standard deviation
function Color.randomize(color, diff, rng)
    rng = rng or color._rng or ROT.RNG
    local result = {}
    if type(diff) ~= 'table' then
        local diff = rng:random(0, diff)
        for i = 1, #color do
            result[i] = color[i] + diff
        end
    else
        for i = 1, #color do
            result[i] = color[i] + rng:random(0, diff[i])
        end
    end
    return result
end

-- Convert rgb color to hsl
function Color.rgb2hsl(color)
    local r=color[1]/255
    local g=color[2]/255
    local b=color[3]/255
    local a=color[4] and color[4]/255
    local max=math.max(r, g, b)
    local min=math.min(r, g, b)
    local h,s,l=0,0,(max+min)/2

    if max~=min then
        local d=max-min
        s=l>.5 and d/(2-max-min) or d/(max+min)
        if max==r then
            h=(g-b)/d + (g<b and 6 or 0)
        elseif max==g then
            h=(b-r)/d + 2
        elseif max==b then
            h=(r-g)/ d + 4
        end
        h=h/6
    end

    return { h, s, l, a }
end

local function hue2rgb(p, q, t)
    if t<0 then t=t+1 end
    if t>1 then t=t-1 end
    if t<1/6 then return (p+(q-p)*6*t) end
    if t<1/2 then return q end
    if t<2/3 then return (p+(q-p)*(2/3-t)*6) end
    return p
end

-- Convert hsl color to rgb
function Color.hsl2rgb(color)
    local h, s, l = color[1], color[2], color[3]
    local result = {}
    result[4] = color[4] and math.floor(color[4] * 255)
    if s == 0 then
        local value = math.floor(l * 255 + 0.5)
        for i = 1, 3 do
            result[i] = value
        end
    else
        local q=l<.5 and l*(1+s) or l+s-l*s
        local p=2*l-q
        result[1] = math.floor(hue2rgb(p,q,h+1/3)*255 + 0.5)
        result[2] = math.floor(hue2rgb(p,q,h)*255 + 0.5)
        result[3] = math.floor(hue2rgb(p,q,h-1/3)*255 + 0.5)
    end
    return result
end

--- Convert color to RGB string.
-- Get a string that can be fed to Color.fromString()
-- @tparam table color A color table
function Color.toRGB(color)
    return ('rgb(%d,%d,%d)'):format(
        Color._clamp(color[1]), Color._clamp(color[2]), Color._clamp(color[3]))
end

--- Convert color to Hex string
-- Get a string that can be fed to Color.fromString()
-- @tparam table color A color table
function Color.toHex(color)
    return ('#%02x%02x%02x'):format(
        Color._clamp(color[1]), Color._clamp(color[2]), Color._clamp(color[3]))
end

-- limit a number to 0..255
function Color._clamp(n)
    return n<0 and 0 or n>255 and 255 or n
end

function Color.__add(a, b) return add({}, a, b) end
function Color.__mul(a, b) return mul({}, a, b) end

--- Color cache
-- A table of predefined color tables
-- These keys can be passed to Color.fromString()
-- @field black { 0.0, 0.0, 0.0 }
-- @field navy { 0.0, 0.0, 0.5019607843137255 }
-- @field darkblue { 0.0, 0.0, 0.5450980392156862 }
-- @field mediumblue { 0.0, 0.0, 0.803921568627451 }
-- @field blue { 0.0, 0.0, 1.0 }
-- @field darkgreen { 0.0, 0.39215686274509803, 0.0 }
-- @field green { 0.0, 0.5019607843137255, 0.0 }
-- @field teal { 0.0, 0.5019607843137255, 0.5019607843137255 }
-- @field darkcyan { 0.0, 0.5450980392156862, 0.5450980392156862 }
-- @field deepskyblue { 0.0, 0.7490196078431373, 1.0 }
-- @field darkturquoise { 0.0, 0.807843137254902, 0.8196078431372549 }
-- @field mediumspringgreen { 0.0, 0.9803921568627451, 0.6039215686274509 }
-- @field lime { 0.0, 1.0, 0.0 }
-- @field springgreen { 0.0, 1.0, 0.4980392156862745 }
-- @field aqua { 0.0, 1.0, 1.0 }
-- @field cyan { 0.0, 1.0, 1.0 }
-- @field midnightblue { 0.09803921568627451, 0.09803921568627451, 0.4392156862745098 }
-- @field dodgerblue { 0.11764705882352941, 0.5647058823529412, 1.0 }
-- @field forestgreen { 0.13333333333333333, 0.5450980392156862, 0.13333333333333333 }
-- @field seagreen { 0.1803921568627451, 0.5450980392156862, 0.3411764705882353 }
-- @field darkslategray { 0.1843137254901961, 0.30980392156862746, 0.30980392156862746 }
-- @field darkslategrey { 0.1843137254901961, 0.30980392156862746, 0.30980392156862746 }
-- @field limegreen { 0.19607843137254902, 0.803921568627451, 0.19607843137254902 }
-- @field mediumseagreen { 0.23529411764705882, 0.7019607843137254, 0.44313725490196076 }
-- @field turquoise { 0.25098039215686274, 0.8784313725490196, 0.8156862745098039 }
-- @field royalblue { 0.2549019607843137, 0.4117647058823529, 0.8823529411764706 }
-- @field steelblue { 0.27450980392156865, 0.5098039215686274, 0.7058823529411765 }
-- @field darkslateblue { 0.2823529411764706, 0.23921568627450981, 0.5450980392156862 }
-- @field mediumturquoise { 0.2823529411764706, 0.8196078431372549, 0.8 }
-- @field indigo { 0.29411764705882354, 0.0, 0.5098039215686274 }
-- @field darkolivegreen { 0.3333333333333333, 0.4196078431372549, 0.1843137254901961 }
-- @field cadetblue { 0.37254901960784315, 0.6196078431372549, 0.6274509803921569 }
-- @field cornflowerblue { 0.39215686274509803, 0.5843137254901961, 0.9294117647058824 }
-- @field mediumaquamarine { 0.4, 0.803921568627451, 0.6666666666666666 }
-- @field dimgray { 0.4117647058823529, 0.4117647058823529, 0.4117647058823529 }
-- @field dimgrey { 0.4117647058823529, 0.4117647058823529, 0.4117647058823529 }
-- @field slateblue { 0.41568627450980394, 0.35294117647058826, 0.803921568627451 }
-- @field olivedrab { 0.4196078431372549, 0.5568627450980392, 0.13725490196078433 }
-- @field slategray { 0.4392156862745098, 0.5019607843137255, 0.5647058823529412 }
-- @field slategrey { 0.4392156862745098, 0.5019607843137255, 0.5647058823529412 }
-- @field lightslategray { 0.4666666666666667, 0.5333333333333333, 0.6 }
-- @field lightslategrey { 0.4666666666666667, 0.5333333333333333, 0.6 }
-- @field mediumslateblue { 0.4823529411764706, 0.40784313725490196, 0.9333333333333333 }
-- @field lawngreen { 0.48627450980392156, 0.9882352941176471, 0.0 }
-- @field chartreuse { 0.4980392156862745, 1.0, 0.0 }
-- @field aquamarine { 0.4980392156862745, 1.0, 0.8313725490196079 }
-- @field maroon { 0.5019607843137255, 0.0, 0.0 }
-- @field purple { 0.5019607843137255, 0.0, 0.5019607843137255 }
-- @field olive { 0.5019607843137255, 0.5019607843137255, 0.0 }
-- @field gray { 0.5019607843137255, 0.5019607843137255, 0.5019607843137255 }
-- @field grey { 0.5019607843137255, 0.5019607843137255, 0.5019607843137255 }
-- @field skyblue { 0.5294117647058824, 0.807843137254902, 0.9215686274509803 }
-- @field lightskyblue { 0.5294117647058824, 0.807843137254902, 0.9803921568627451 }
-- @field blueviolet { 0.5411764705882353, 0.16862745098039217, 0.8862745098039215 }
-- @field darkred { 0.5450980392156862, 0.0, 0.0 }
-- @field darkmagenta { 0.5450980392156862, 0.0, 0.5450980392156862 }
-- @field saddlebrown { 0.5450980392156862, 0.27058823529411763, 0.07450980392156863 }
-- @field darkseagreen { 0.5607843137254902, 0.7372549019607844, 0.5607843137254902 }
-- @field lightgreen { 0.5647058823529412, 0.9333333333333333, 0.5647058823529412 }
-- @field mediumpurple { 0.5764705882352941, 0.4392156862745098, 0.8470588235294118 }
-- @field darkviolet { 0.5803921568627451, 0.0, 0.8274509803921568 }
-- @field palegreen { 0.596078431372549, 0.984313725490196, 0.596078431372549 }
-- @field darkorchid { 0.6, 0.19607843137254902, 0.8 }
-- @field yellowgreen { 0.6039215686274509, 0.803921568627451, 0.19607843137254902 }
-- @field sienna { 0.6274509803921569, 0.3215686274509804, 0.17647058823529413 }
-- @field brown { 0.6470588235294118, 0.16470588235294117, 0.16470588235294117 }
-- @field darkgray { 0.6627450980392157, 0.6627450980392157, 0.6627450980392157 }
-- @field darkgrey { 0.6627450980392157, 0.6627450980392157, 0.6627450980392157 }
-- @field lightblue { 0.6784313725490196, 0.8470588235294118, 0.9019607843137255 }
-- @field greenyellow { 0.6784313725490196, 1.0, 0.1843137254901961 }
-- @field paleturquoise { 0.6862745098039216, 0.9333333333333333, 0.9333333333333333 }
-- @field lightsteelblue { 0.6901960784313725, 0.7686274509803922, 0.8705882352941177 }
-- @field powderblue { 0.6901960784313725, 0.8784313725490196, 0.9019607843137255 }
-- @field firebrick { 0.6980392156862745, 0.13333333333333333, 0.13333333333333333 }
-- @field darkgoldenrod { 0.7215686274509804, 0.5254901960784314, 0.043137254901960784 }
-- @field mediumorchid { 0.7294117647058823, 0.3333333333333333, 0.8274509803921568 }
-- @field rosybrown { 0.7372549019607844, 0.5607843137254902, 0.5607843137254902 }
-- @field darkkhaki { 0.7411764705882353, 0.7176470588235294, 0.4196078431372549 }
-- @field silver { 0.7529411764705882, 0.7529411764705882, 0.7529411764705882 }
-- @field mediumvioletred { 0.7803921568627451, 0.08235294117647059, 0.5215686274509804 }
-- @field indianred { 0.803921568627451, 0.3607843137254902, 0.3607843137254902 }
-- @field peru { 0.803921568627451, 0.5215686274509804, 0.24705882352941178 }
-- @field chocolate { 0.8235294117647058, 0.4117647058823529, 0.11764705882352941 }
-- @field tan { 0.8235294117647058, 0.7058823529411765, 0.5490196078431373 }
-- @field lightgray { 0.8274509803921568, 0.8274509803921568, 0.8274509803921568 }
-- @field lightgrey { 0.8274509803921568, 0.8274509803921568, 0.8274509803921568 }
-- @field palevioletred { 0.8470588235294118, 0.4392156862745098, 0.5764705882352941 }
-- @field thistle { 0.8470588235294118, 0.7490196078431373, 0.8470588235294118 }
-- @field orchid { 0.8549019607843137, 0.4392156862745098, 0.8392156862745098 }
-- @field goldenrod { 0.8549019607843137, 0.6470588235294118, 0.12549019607843137 }
-- @field crimson { 0.8627450980392157, 0.0784313725490196, 0.23529411764705882 }
-- @field gainsboro { 0.8627450980392157, 0.8627450980392157, 0.8627450980392157 }
-- @field plum { 0.8666666666666667, 0.6274509803921569, 0.8666666666666667 }
-- @field burlywood { 0.8705882352941177, 0.7215686274509804, 0.5294117647058824 }
-- @field lightcyan { 0.8784313725490196, 1.0, 1.0 }
-- @field lavender { 0.9019607843137255, 0.9019607843137255, 0.9803921568627451 }
-- @field darksalmon { 0.9137254901960784, 0.5882352941176471, 0.47843137254901963 }
-- @field violet { 0.9333333333333333, 0.5098039215686274, 0.9333333333333333 }
-- @field palegoldenrod { 0.9333333333333333, 0.9098039215686274, 0.6666666666666666 }
-- @field lightcoral { 0.9411764705882353, 0.5019607843137255, 0.5019607843137255 }
-- @field khaki { 0.9411764705882353, 0.9019607843137255, 0.5490196078431373 }
-- @field aliceblue { 0.9411764705882353, 0.9725490196078431, 1.0 }
-- @field honeydew { 0.9411764705882353, 1.0, 0.9411764705882353 }
-- @field azure { 0.9411764705882353, 1.0, 1.0 }
-- @field sandybrown { 0.9568627450980393, 0.6431372549019608, 0.3764705882352941 }
-- @field wheat { 0.9607843137254902, 0.8705882352941177, 0.7019607843137254 }
-- @field beige { 0.9607843137254902, 0.9607843137254902, 0.8627450980392157 }
-- @field whitesmoke { 0.9607843137254902, 0.9607843137254902, 0.9607843137254902 }
-- @field mintcream { 0.9607843137254902, 1.0, 0.9803921568627451 }
-- @field ghostwhite { 0.9725490196078431, 0.9725490196078431, 1.0 }
-- @field salmon { 0.9803921568627451, 0.5019607843137255, 0.4470588235294118 }
-- @field antiquewhite { 0.9803921568627451, 0.9215686274509803, 0.8431372549019608 }
-- @field linen { 0.9803921568627451, 0.9411764705882353, 0.9019607843137255 }
-- @field lightgoldenrodyellow { 0.9803921568627451, 0.9803921568627451, 0.8235294117647058 }
-- @field oldlace { 0.9921568627450981, 0.9607843137254902, 0.9019607843137255 }
-- @field red { 1.0, 0.0, 0.0 }
-- @field fuchsia { 1.0, 0.0, 1.0 }
-- @field magenta { 1.0, 0.0, 1.0 }
-- @field deeppink { 1.0, 0.0784313725490196, 0.5764705882352941 }
-- @field orangered { 1.0, 0.27058823529411763, 0.0 }
-- @field tomato { 1.0, 0.38823529411764707, 0.2784313725490196 }
-- @field hotpink { 1.0, 0.4117647058823529, 0.7058823529411765 }
-- @field coral { 1.0, 0.4980392156862745, 0.3137254901960784 }
-- @field darkorange { 1.0, 0.5490196078431373, 0.0 }
-- @field lightsalmon { 1.0, 0.6274509803921569, 0.47843137254901963 }
-- @field orange { 1.0, 0.6470588235294118, 0.0 }
-- @field lightpink { 1.0, 0.7137254901960784, 0.7568627450980392 }
-- @field pink { 1.0, 0.7529411764705882, 0.796078431372549 }
-- @field gold { 1.0, 0.8431372549019608, 0.0 }
-- @field peachpuff { 1.0, 0.8549019607843137, 0.7254901960784313 }
-- @field navajowhite { 1.0, 0.8705882352941177, 0.6784313725490196 }
-- @field moccasin { 1.0, 0.8941176470588236, 0.7098039215686275 }
-- @field bisque { 1.0, 0.8941176470588236, 0.7686274509803922 }
-- @field mistyrose { 1.0, 0.8941176470588236, 0.8823529411764706 }
-- @field blanchedalmond { 1.0, 0.9215686274509803, 0.803921568627451 }
-- @field papayawhip { 1.0, 0.9372549019607843, 0.8352941176470589 }
-- @field lavenderblush { 1.0, 0.9411764705882353, 0.9607843137254902 }
-- @field seashell { 1.0, 0.9607843137254902, 0.9333333333333333 }
-- @field cornsilk { 1.0, 0.9725490196078431, 0.8627450980392157 }
-- @field lemonchiffon { 1.0, 0.9803921568627451, 0.803921568627451 }
-- @field floralwhite { 1.0, 0.9803921568627451, 0.9411764705882353 }
-- @field snow { 1.0, 0.9803921568627451, 0.9803921568627451 }
-- @field yellow { 1.0, 1.0, 0.0 }
-- @field lightyellow { 1.0, 1.0, 0.8784313725490196 }
-- @field ivory { 1.0, 1.0, 0.9411764705882353 }
-- @field white { 1.0, 1.0, 1.0 }
-- @table Color._cache

Color._cached={
    black= { 0,  0, 0 },
    navy= { 0.0, 0.0, 0.5019607843137255 },
    darkblue= { 0.0, 0.0, 0.5450980392156862 },
    mediumblue= { 0.0, 0.0, 0.803921568627451 },
    blue= { 0.0, 0.0, 1.0 },
    darkgreen= { 0.0, 0.39215686274509803, 0.0 },
    green= { 0.0, 0.5019607843137255, 0.0 },
    teal= { 0.0, 0.5019607843137255, 0.5019607843137255 },
    darkcyan= { 0.0, 0.5450980392156862, 0.5450980392156862 },
    deepskyblue= { 0.0, 0.7490196078431373, 1.0 },
    darkturquoise= { 0.0, 0.807843137254902, 0.8196078431372549 },
    mediumspringgreen= { 0.0, 0.9803921568627451, 0.6039215686274509 },
    lime= { 0.0, 1.0, 0.0 },
    springgreen= { 0.0, 1.0, 0.4980392156862745 },
    aqua= { 0.0, 1.0, 1.0 },
    cyan= { 0.0, 1.0, 1.0 },
    midnightblue= { 0.09803921568627451, 0.09803921568627451, 0.4392156862745098 },
    dodgerblue= { 0.11764705882352941, 0.5647058823529412, 1.0 },
    forestgreen= { 0.13333333333333333, 0.5450980392156862, 0.13333333333333333 },
    seagreen= { 0.1803921568627451, 0.5450980392156862, 0.3411764705882353 },
    darkslategray= { 0.1843137254901961, 0.30980392156862746, 0.30980392156862746 },
    darkslategrey= { 0.1843137254901961, 0.30980392156862746, 0.30980392156862746 },
    limegreen= { 0.19607843137254902, 0.803921568627451, 0.19607843137254902 },
    mediumseagreen= { 0.23529411764705882, 0.7019607843137254, 0.44313725490196076 },
    turquoise= { 0.25098039215686274, 0.8784313725490196, 0.8156862745098039 },
    royalblue= { 0.2549019607843137, 0.4117647058823529, 0.8823529411764706 },
    steelblue= { 0.27450980392156865, 0.5098039215686274, 0.7058823529411765 },
    darkslateblue= { 0.2823529411764706, 0.23921568627450981, 0.5450980392156862 },
    mediumturquoise= { 0.2823529411764706, 0.8196078431372549, 0.8 },
    indigo= { 0.29411764705882354, 0.0, 0.5098039215686274 },
    darkolivegreen= { 0.3333333333333333, 0.4196078431372549, 0.1843137254901961 },
    cadetblue= { 0.37254901960784315, 0.6196078431372549, 0.6274509803921569 },
    cornflowerblue= { 0.39215686274509803, 0.5843137254901961, 0.9294117647058824 },
    mediumaquamarine= { 0.4, 0.803921568627451, 0.6666666666666666 },
    dimgray= { 0.4117647058823529, 0.4117647058823529, 0.4117647058823529 },
    dimgrey= { 0.4117647058823529, 0.4117647058823529, 0.4117647058823529 },
    slateblue= { 0.41568627450980394, 0.35294117647058826, 0.803921568627451 },
    olivedrab= { 0.4196078431372549, 0.5568627450980392, 0.13725490196078433 },
    slategray= { 0.4392156862745098, 0.5019607843137255, 0.5647058823529412 },
    slategrey= { 0.4392156862745098, 0.5019607843137255, 0.5647058823529412 },
    lightslategray= { 0.4666666666666667, 0.5333333333333333, 0.6 },
    lightslategrey= { 0.4666666666666667, 0.5333333333333333, 0.6 },
    mediumslateblue= { 0.4823529411764706, 0.40784313725490196, 0.9333333333333333 },
    lawngreen= { 0.48627450980392156, 0.9882352941176471, 0.0 },
    chartreuse= { 0.4980392156862745, 1.0, 0.0 },
    aquamarine= { 0.4980392156862745, 1.0, 0.8313725490196079 },
    maroon= { 0.5019607843137255, 0.0, 0.0 },
    purple= { 0.5019607843137255, 0.0, 0.5019607843137255 },
    olive= { 0.5019607843137255, 0.5019607843137255, 0.0 },
    gray= { 0.5019607843137255, 0.5019607843137255, 0.5019607843137255 },
    grey= { 0.5019607843137255, 0.5019607843137255, 0.5019607843137255 },
    skyblue= { 0.5294117647058824, 0.807843137254902, 0.9215686274509803 },
    lightskyblue= { 0.5294117647058824, 0.807843137254902, 0.9803921568627451 },
    blueviolet= { 0.5411764705882353, 0.16862745098039217, 0.8862745098039215 },
    darkred= { 0.5450980392156862, 0.0, 0.0 },
    darkmagenta= { 0.5450980392156862, 0.0, 0.5450980392156862 },
    saddlebrown= { 0.5450980392156862, 0.27058823529411763, 0.07450980392156863 },
    darkseagreen= { 0.5607843137254902, 0.7372549019607844, 0.5607843137254902 },
    lightgreen= { 0.5647058823529412, 0.9333333333333333, 0.5647058823529412 },
    mediumpurple= { 0.5764705882352941, 0.4392156862745098, 0.8470588235294118 },
    darkviolet= { 0.5803921568627451, 0.0, 0.8274509803921568 },
    palegreen= { 0.596078431372549, 0.984313725490196, 0.596078431372549 },
    darkorchid= { 0.6, 0.19607843137254902, 0.8 },
    yellowgreen= { 0.6039215686274509, 0.803921568627451, 0.19607843137254902 },
    sienna= { 0.6274509803921569, 0.3215686274509804, 0.17647058823529413 },
    brown= { 0.6470588235294118, 0.16470588235294117, 0.16470588235294117 },
    darkgray= { 0.6627450980392157, 0.6627450980392157, 0.6627450980392157 },
    darkgrey= { 0.6627450980392157, 0.6627450980392157, 0.6627450980392157 },
    lightblue= { 0.6784313725490196, 0.8470588235294118, 0.9019607843137255 },
    greenyellow= { 0.6784313725490196, 1.0, 0.1843137254901961 },
    paleturquoise= { 0.6862745098039216, 0.9333333333333333, 0.9333333333333333 },
    lightsteelblue= { 0.6901960784313725, 0.7686274509803922, 0.8705882352941177 },
    powderblue= { 0.6901960784313725, 0.8784313725490196, 0.9019607843137255 },
    firebrick= { 0.6980392156862745, 0.13333333333333333, 0.13333333333333333 },
    darkgoldenrod= { 0.7215686274509804, 0.5254901960784314, 0.043137254901960784 },
    mediumorchid= { 0.7294117647058823, 0.3333333333333333, 0.8274509803921568 },
    rosybrown= { 0.7372549019607844, 0.5607843137254902, 0.5607843137254902 },
    darkkhaki= { 0.7411764705882353, 0.7176470588235294, 0.4196078431372549 },
    silver= { 0.7529411764705882, 0.7529411764705882, 0.7529411764705882 },
    mediumvioletred= { 0.7803921568627451, 0.08235294117647059, 0.5215686274509804 },
    indianred= { 0.803921568627451, 0.3607843137254902, 0.3607843137254902 },
    peru= { 0.803921568627451, 0.5215686274509804, 0.24705882352941178 },
    chocolate= { 0.8235294117647058, 0.4117647058823529, 0.11764705882352941 },
    tan= { 0.8235294117647058, 0.7058823529411765, 0.5490196078431373 },
    lightgray= { 0.8274509803921568, 0.8274509803921568, 0.8274509803921568 },
    lightgrey= { 0.8274509803921568, 0.8274509803921568, 0.8274509803921568 },
    palevioletred= { 0.8470588235294118, 0.4392156862745098, 0.5764705882352941 },
    thistle= { 0.8470588235294118, 0.7490196078431373, 0.8470588235294118 },
    orchid= { 0.8549019607843137, 0.4392156862745098, 0.8392156862745098 },
    goldenrod= { 0.8549019607843137, 0.6470588235294118, 0.12549019607843137 },
    crimson= { 0.8627450980392157, 0.0784313725490196, 0.23529411764705882 },
    gainsboro= { 0.8627450980392157, 0.8627450980392157, 0.8627450980392157 },
    plum= { 0.8666666666666667, 0.6274509803921569, 0.8666666666666667 },
    burlywood= { 0.8705882352941177, 0.7215686274509804, 0.5294117647058824 },
    lightcyan= { 0.8784313725490196, 1.0, 1.0 },
    lavender= { 0.9019607843137255, 0.9019607843137255, 0.9803921568627451 },
    darksalmon= { 0.9137254901960784, 0.5882352941176471, 0.47843137254901963 },
    violet= { 0.9333333333333333, 0.5098039215686274, 0.9333333333333333 },
    palegoldenrod= { 0.9333333333333333, 0.9098039215686274, 0.6666666666666666 },
    lightcoral= { 0.9411764705882353, 0.5019607843137255, 0.5019607843137255 },
    khaki= { 0.9411764705882353, 0.9019607843137255, 0.5490196078431373 },
    aliceblue= { 0.9411764705882353, 0.9725490196078431, 1.0 },
    honeydew= { 0.9411764705882353, 1.0, 0.9411764705882353 },
    azure= { 0.9411764705882353, 1.0, 1.0 },
    sandybrown= { 0.9568627450980393, 0.6431372549019608, 0.3764705882352941 },
    wheat= { 0.9607843137254902, 0.8705882352941177, 0.7019607843137254 },
    beige= { 0.9607843137254902, 0.9607843137254902, 0.8627450980392157 },
    whitesmoke= { 0.9607843137254902, 0.9607843137254902, 0.9607843137254902 },
    mintcream= { 0.9607843137254902, 1.0, 0.9803921568627451 },
    ghostwhite= { 0.9725490196078431, 0.9725490196078431, 1.0 },
    salmon= { 0.9803921568627451, 0.5019607843137255, 0.4470588235294118 },
    antiquewhite= { 0.9803921568627451, 0.9215686274509803, 0.8431372549019608 },
    linen= { 0.9803921568627451, 0.9411764705882353, 0.9019607843137255 },
    lightgoldenrodyellow= { 0.9803921568627451, 0.9803921568627451, 0.8235294117647058 },
    oldlace= { 0.9921568627450981, 0.9607843137254902, 0.9019607843137255 },
    red= { 1.0, 0.0, 0.0 },
    fuchsia= { 1.0, 0.0, 1.0 },
    magenta= { 1.0, 0.0, 1.0 },
    deeppink= { 1.0, 0.0784313725490196, 0.5764705882352941 },
    orangered= { 1.0, 0.27058823529411763, 0.0 },
    tomato= { 1.0, 0.38823529411764707, 0.2784313725490196 },
    hotpink= { 1.0, 0.4117647058823529, 0.7058823529411765 },
    coral= { 1.0, 0.4980392156862745, 0.3137254901960784 },
    darkorange= { 1.0, 0.5490196078431373, 0.0 },
    lightsalmon= { 1.0, 0.6274509803921569, 0.47843137254901963 },
    orange= { 1.0, 0.6470588235294118, 0.0 },
    lightpink= { 1.0, 0.7137254901960784, 0.7568627450980392 },
    pink= { 1.0, 0.7529411764705882, 0.796078431372549 },
    gold= { 1.0, 0.8431372549019608, 0.0 },
    peachpuff= { 1.0, 0.8549019607843137, 0.7254901960784313 },
    navajowhite= { 1.0, 0.8705882352941177, 0.6784313725490196 },
    moccasin= { 1.0, 0.8941176470588236, 0.7098039215686275 },
    bisque= { 1.0, 0.8941176470588236, 0.7686274509803922 },
    mistyrose= { 1.0, 0.8941176470588236, 0.8823529411764706 },
    blanchedalmond= { 1.0, 0.9215686274509803, 0.803921568627451 },
    papayawhip= { 1.0, 0.9372549019607843, 0.8352941176470589 },
    lavenderblush= { 1.0, 0.9411764705882353, 0.9607843137254902 },
    seashell= { 1.0, 0.9607843137254902, 0.9333333333333333 },
    cornsilk= { 1.0, 0.9725490196078431, 0.8627450980392157 },
    lemonchiffon= { 1.0, 0.9803921568627451, 0.803921568627451 },
    floralwhite= { 1.0, 0.9803921568627451, 0.9411764705882353 },
    snow= { 1.0, 0.9803921568627451, 0.9803921568627451 },
    yellow= { 1.0, 1.0, 0.0 },
    lightyellow= { 1.0, 1.0, 0.8784313725490196 },
    ivory= { 1.0, 1.0, 0.9411764705882353 },
    white= { 1.0, 1.0, 1.0 }
}

return Color

