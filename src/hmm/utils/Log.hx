package hmm.utils;

using hmm.utils.AnsiColors;

class Log {
  public static function println(message : String) {
    Sys.println(message);
  }

  public static function debug(message : String) {
    println(message.blue());
  }

  public static function info(message : String) {
    println(message.green());
  }

  public static function warning(message : String) {
    println(message.magenta());
  }

  public static function error(message : String) {
    println(message.red());
  }

  public static function die(message : String) {
    error(message);
    Sys.exit(1);
  }

  public static function shell(message : String) {
    println(message.yellow());
  }
}
