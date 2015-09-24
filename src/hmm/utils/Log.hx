package hmm.utils;

using hmm.utils.AnsiColors;

class Log {
  public static function debug(message : String) {
    Sys.println(message.blue());
  }

  public static function info(message : String) {
    Sys.println(message.green());
  }

  public static function warning(message : String) {
    Sys.println(message.magenta());
  }

  public static function error(message : String) {
    Sys.println(message.red());
  }

  public static function shell(message : String) {
    Sys.println(message.magenta());
  }
}
