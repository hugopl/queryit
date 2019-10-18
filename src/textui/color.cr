module TextUi
  enum ColorMode
    Current       = 0
    Normal        = 1
    Just256Colors = 2
    Just216Colors = 3
    Grayscale     = 4
  end

  enum Attr
    Bold      = 0x0100
    Underline = 0x0200
    Reverse   = 0x0400
  end

  enum Color
    Black             =   0 # #000000
    Maroon            =   1 # #800000
    Green             =   2 # #008000
    Olive             =   3 # #808000
    Navy              =   4 # #000080
    Purple            =   5 # #800080
    Teal              =   6 # #008080
    Silver            =   7 # #c0c0c0
    Grey              =   8 # #808080
    Red               =   9 # #ff0000
    Lime              =  10 # #00ff00
    Yellow            =  11 # #ffff00
    Blue              =  12 # #0000ff
    Fuchsia           =  13 # #ff00ff
    Aqua              =  14 # #00ffff
    White             =  15 # #ffffff
    Grey1             =  16 # #000000
    NavyBlue          =  17 # #00005f
    DarkBlue          =  18 # #000087
    Blue1             =  19 # #0000af
    Blue2             =  20 # #0000d7
    Blue3             =  21 # #0000ff
    DarkGreen         =  22 # #005f00
    DeepSkyBlue       =  23 # #005f5f
    DeepSkyBlue1      =  24 # #005f87
    DeepSkyBlue2      =  25 # #005faf
    DodgerBlue        =  26 # #005fd7
    DodgerBlue1       =  27 # #005fff
    Green1            =  28 # #008700
    SpringGreen       =  29 # #00875f
    Turquoise         =  30 # #008787
    DeepSkyBlue3      =  31 # #0087af
    DeepSkyBlue4      =  32 # #0087d7
    DodgerBlue2       =  33 # #0087ff
    Green2            =  34 # #00af00
    SpringGreen1      =  35 # #00af5f
    DarkCyan          =  36 # #00af87
    LightSeaGreen     =  37 # #00afaf
    DeepSkyBlue5      =  38 # #00afd7
    DeepSkyBlue6      =  39 # #00afff
    Green3            =  40 # #00d700
    SpringGreen2      =  41 # #00d75f
    SpringGreen3      =  42 # #00d787
    Cyan              =  43 # #00d7af
    DarkTurquoise     =  44 # #00d7d7
    Turquoise1        =  45 # #00d7ff
    Green4            =  46 # #00ff00
    SpringGreen4      =  47 # #00ff5f
    SpringGreen5      =  48 # #00ff87
    MediumSpringGreen =  49 # #00ffaf
    Cyan1             =  50 # #00ffd7
    Cyan2             =  51 # #00ffff
    DarkRed           =  52 # #5f0000
    DeepPink          =  53 # #5f005f
    Purple1           =  54 # #5f0087
    Purple2           =  55 # #5f00af
    Purple3           =  56 # #5f00d7
    BlueViolet        =  57 # #5f00ff
    Orange            =  58 # #5f5f00
    Grey2             =  59 # #5f5f5f
    MediumPurple      =  60 # #5f5f87
    SlateBlue         =  61 # #5f5faf
    SlateBlue1        =  62 # #5f5fd7
    RoyalBlue         =  63 # #5f5fff
    Chartreuse        =  64 # #5f8700
    DarkSeaGreen      =  65 # #5f875f
    PaleTurquoise     =  66 # #5f8787
    SteelBlue         =  67 # #5f87af
    SteelBlue1        =  68 # #5f87d7
    CornflowerBlue    =  69 # #5f87ff
    Chartreuse1       =  70 # #5faf00
    DarkSeaGreen1     =  71 # #5faf5f
    CadetBlue         =  72 # #5faf87
    CadetBlue1        =  73 # #5fafaf
    SkyBlue           =  74 # #5fafd7
    SteelBlue2        =  75 # #5fafff
    Chartreuse2       =  76 # #5fd700
    PaleGreen         =  77 # #5fd75f
    SeaGreen          =  78 # #5fd787
    Aquamarine        =  79 # #5fd7af
    MediumTurquoise   =  80 # #5fd7d7
    SteelBlue3        =  81 # #5fd7ff
    Chartreuse3       =  82 # #5fff00
    SeaGreen1         =  83 # #5fff5f
    SeaGreen2         =  84 # #5fff87
    SeaGreen3         =  85 # #5fffaf
    Aquamarine1       =  86 # #5fffd7
    DarkSlateGray     =  87 # #5fffff
    DarkRed1          =  88 # #870000
    DeepPink1         =  89 # #87005f
    DarkMagenta       =  90 # #870087
    DarkMagenta1      =  91 # #8700af
    DarkViolet        =  92 # #8700d7
    Purple4           =  93 # #8700ff
    Orange1           =  94 # #875f00
    LightPink         =  95 # #875f5f
    Plum              =  96 # #875f87
    MediumPurple1     =  97 # #875faf
    MediumPurple2     =  98 # #875fd7
    SlateBlue2        =  99 # #875fff
    Yellow1           = 100 # #878700
    Wheat             = 101 # #87875f
    Grey3             = 102 # #878787
    LightSlateGrey    = 103 # #8787af
    MediumPurple3     = 104 # #8787d7
    LightSlateBlue    = 105 # #8787ff
    Yellow2           = 106 # #87af00
    DarkOliveGreen    = 107 # #87af5f
    DarkSeaGreen2     = 108 # #87af87
    LightSkyBlue      = 109 # #87afaf
    LightSkyBlue1     = 110 # #87afd7
    SkyBlue1          = 111 # #87afff
    Chartreuse4       = 112 # #87d700
    DarkOliveGreen1   = 113 # #87d75f
    PaleGreen1        = 114 # #87d787
    DarkSeaGreen3     = 115 # #87d7af
    DarkSlateGray1    = 116 # #87d7d7
    SkyBlue2          = 117 # #87d7ff
    Chartreuse5       = 118 # #87ff00
    LightGreen        = 119 # #87ff5f
    LightGreen1       = 120 # #87ff87
    PaleGreen2        = 121 # #87ffaf
    Aquamarine2       = 122 # #87ffd7
    DarkSlateGray2    = 123 # #87ffff
    Red1              = 124 # #af0000
    DeepPink2         = 125 # #af005f
    MediumVioletRed   = 126 # #af0087
    Magenta           = 127 # #af00af
    DarkViolet1       = 128 # #af00d7
    Purple5           = 129 # #af00ff
    DarkOrange        = 130 # #af5f00
    IndianRed         = 131 # #af5f5f
    HotPink           = 132 # #af5f87
    MediumOrchid      = 133 # #af5faf
    MediumOrchid1     = 134 # #af5fd7
    MediumPurple4     = 135 # #af5fff
    DarkGoldenrod     = 136 # #af8700
    LightSalmon       = 137 # #af875f
    RosyBrown         = 138 # #af8787
    Grey4             = 139 # #af87af
    MediumPurple5     = 140 # #af87d7
    MediumPurple6     = 141 # #af87ff
    Gold              = 142 # #afaf00
    DarkKhaki         = 143 # #afaf5f
    NavajoWhite       = 144 # #afaf87
    Grey5             = 145 # #afafaf
    LightSteelBlue    = 146 # #afafd7
    LightSteelBlue1   = 147 # #afafff
    Yellow3           = 148 # #afd700
    DarkOliveGreen2   = 149 # #afd75f
    DarkSeaGreen4     = 150 # #afd787
    DarkSeaGreen5     = 151 # #afd7af
    LightCyan         = 152 # #afd7d7
    LightSkyBlue2     = 153 # #afd7ff
    GreenYellow       = 154 # #afff00
    DarkOliveGreen3   = 155 # #afff5f
    PaleGreen3        = 156 # #afff87
    DarkSeaGreen6     = 157 # #afffaf
    DarkSeaGreen7     = 158 # #afffd7
    PaleTurquoise1    = 159 # #afffff
    Red2              = 160 # #d70000
    DeepPink3         = 161 # #d7005f
    DeepPink4         = 162 # #d70087
    Magenta1          = 163 # #d700af
    Magenta2          = 164 # #d700d7
    Magenta3          = 165 # #d700ff
    DarkOrange1       = 166 # #d75f00
    IndianRed1        = 167 # #d75f5f
    HotPink1          = 168 # #d75f87
    HotPink2          = 169 # #d75faf
    Orchid            = 170 # #d75fd7
    MediumOrchid2     = 171 # #d75fff
    Orange2           = 172 # #d78700
    LightSalmon1      = 173 # #d7875f
    LightPink1        = 174 # #d78787
    Pink              = 175 # #d787af
    Plum1             = 176 # #d787d7
    Violet            = 177 # #d787ff
    Gold1             = 178 # #d7af00
    LightGoldenrod    = 179 # #d7af5f
    Tan               = 180 # #d7af87
    MistyRose         = 181 # #d7afaf
    Thistle           = 182 # #d7afd7
    Plum2             = 183 # #d7afff
    Yellow4           = 184 # #d7d700
    Khaki             = 185 # #d7d75f
    LightGoldenrod1   = 186 # #d7d787
    LightYellow       = 187 # #d7d7af
    Grey6             = 188 # #d7d7d7
    LightSteelBlue2   = 189 # #d7d7ff
    Yellow5           = 190 # #d7ff00
    DarkOliveGreen4   = 191 # #d7ff5f
    DarkOliveGreen5   = 192 # #d7ff87
    DarkSeaGreen8     = 193 # #d7ffaf
    Honeydew          = 194 # #d7ffd7
    LightCyan1        = 195 # #d7ffff
    Red3              = 196 # #ff0000
    DeepPink5         = 197 # #ff005f
    DeepPink6         = 198 # #ff0087
    DeepPink7         = 199 # #ff00af
    Magenta4          = 200 # #ff00d7
    Magenta5          = 201 # #ff00ff
    OrangeRed         = 202 # #ff5f00
    IndianRed2        = 203 # #ff5f5f
    IndianRed3        = 204 # #ff5f87
    HotPink3          = 205 # #ff5faf
    HotPink4          = 206 # #ff5fd7
    MediumOrchid3     = 207 # #ff5fff
    DarkOrange2       = 208 # #ff8700
    Salmon            = 209 # #ff875f
    LightCoral        = 210 # #ff8787
    PaleVioletRed     = 211 # #ff87af
    Orchid1           = 212 # #ff87d7
    Orchid2           = 213 # #ff87ff
    Orange3           = 214 # #ffaf00
    SandyBrown        = 215 # #ffaf5f
    LightSalmon2      = 216 # #ffaf87
    LightPink2        = 217 # #ffafaf
    Pink1             = 218 # #ffafd7
    Plum3             = 219 # #ffafff
    Gold2             = 220 # #ffd700
    LightGoldenrod2   = 221 # #ffd75f
    LightGoldenrod3   = 222 # #ffd787
    NavajoWhite1      = 223 # #ffd7af
    MistyRose1        = 224 # #ffd7d7
    Thistle1          = 225 # #ffd7ff
    Yellow6           = 226 # #ffff00
    LightGoldenrod4   = 227 # #ffff5f
    Khaki1            = 228 # #ffff87
    Wheat1            = 229 # #ffffaf
    Cornsilk          = 230 # #ffffd7
    Grey7             = 231 # #ffffff
    Grey8             = 232 # #080808
    Grey9             = 233 # #121212
    Grey10            = 234 # #1c1c1c
    Grey11            = 235 # #262626
    Grey12            = 236 # #303030
    Grey13            = 237 # #3a3a3a
    Grey14            = 238 # #444444
    Grey15            = 239 # #4e4e4e
    Grey16            = 240 # #585858
    Grey17            = 241 # #626262
    Grey18            = 242 # #6c6c6c
    Grey19            = 243 # #767676
    Grey20            = 244 # #808080
    Grey21            = 245 # #8a8a8a
    Grey22            = 246 # #949494
    Grey23            = 247 # #9e9e9e
    Grey24            = 248 # #a8a8a8
    Grey25            = 249 # #b2b2b2
    Grey26            = 250 # #bcbcbc
    Grey27            = 251 # #c6c6c6
    Grey28            = 252 # #d0d0d0
    Grey29            = 253 # #dadada
    Grey30            = 254 # #e4e4e4
    Grey31            = 255 # #eeeeee

    def |(attr : Attr) : UInt16
      to_u16 | attr.to_u16
    end
  end
end
