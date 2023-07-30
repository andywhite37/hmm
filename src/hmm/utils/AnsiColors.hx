package hmm.utils;

enum abstract AnsiColor(String) to String {
  var Black = '\033[0;30m';
  var Red = '\033[0;31m';
  var Green = '\033[0;32m';
  var Yellow = '\033[0;33m';
  var Blue = '\033[0;34m';
  var Magenta = '\033[0;35m';
  var Cyan = '\033[0;36m';
  var Gray = '\033[0;37m';
  var White = '\033[1;37m';
  var None = '\033[0;0m';
}

class AnsiColors {
  public static var disabled:Bool;

  public static function red(input:String) {
    return color(input, Red);
  }

  public static function green(input:String) {
    return color(input, Green);
  }

  public static function yellow(input:String) {
    return color(input, Yellow);
  }

  public static function blue(input:String) {
    return color(input, Blue);
  }

  public static function magenta(input:String) {
    return color(input, Magenta);
  }

  public static function cyan(input:String) {
    return color(input, Cyan);
  }

  public static function gray(input:String) {
    return color(input, Gray);
  }

  public static function white(input:String) {
    return color(input, White);
  }

  public static function none(input:String) {
    return color(input, None);
  }

  public static function color(input:String, ansiColor:AnsiColor):String {
    return disabled ? input : '${ansiColor}$input${AnsiColor.None}';
  }
}
