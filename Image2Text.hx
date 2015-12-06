using StringTools;

class Image2Text
{
  static var pico_pal = [
    [0x00,0x00,0x00], [0x1d,0x2b,0x53], [0x7e,0x25,0x53], [0x00,0x87,0x51],
    [0xab,0x52,0x36], [0x5f,0x57,0x4f], [0xc2,0xc3,0xc7], [0xff,0xf1,0xe8],
    [0xff,0x00,0x4d], [0xff,0xa3,0x00], [0xff,0xf0,0x24], [0x00,0xe7,0x56],
    [0x29,0xad,0xff], [0x83,0x76,0x9c], [0xff,0x77,0xa8], [0xff,0xcc,0xaa]
  ];

  static inline function nearest_col(r:Int, g:Int, b:Int)
  {
    var min_score = 0xff*3;
    var min_idx = 0;

    for (i in 0...pico_pal.length)
    {
      var score =
        Std.int(Math.abs(pico_pal[i][0] - r)) +
        Std.int(Math.abs(pico_pal[i][1] - g)) +
        Std.int(Math.abs(pico_pal[i][2] - b));

      if (score < min_score)
      {
        min_score = score;
        min_idx = i;
      }
    }

    return min_idx;
  }

  static function main()
  {
    if (Sys.args().length <= 0)
    {
      Sys.println("Image2Text <image.png>");
      Sys.exit(-1);
    }

    var image = stb.Image.load(Sys.args()[0], 3);
    if (image == null)
    {
        trace('FAIL: ' + stb.Image.failure_reason());
    }

    trace('DATA: ${image.w} x ${image.h} comp:${image.comp} req_comp:${image.comp} / ${image.bytes.length} bytes');

    if (image.w != 128)
    {
      Sys.println("Sorry - currently only supporting 128 px width :(");
      Sys.exit(-1);
    }

    for (y in 0...image.h)
    {
      var s = '';
      for (x in 0...image.w)
      {
        var r = cast(image.bytes[(y*image.w*image.comp)+(x*image.comp)+0],Int);
        var g = cast(image.bytes[(y*image.w*image.comp)+(x*image.comp)+1],Int);
        var b = cast(image.bytes[(y*image.w*image.comp)+(x*image.comp)+2],Int);
        var idx = nearest_col(r, g, b);
        s += StringTools.hex(idx,1).toLowerCase();
      }

      Sys.println(s);
    }
  }
}
