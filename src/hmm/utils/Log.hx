package hmm.utils;

using hmm.utils.AnsiColors;

class Log {
  public static function debug(message : String) {
    println("DEBUG", message.blue());
  }

  public static function info(message : String) {
    println("INFO", message.green());
  }

  public static function warning(message : String) {
    println("WARN", message.magenta());
  }

  public static function error(message : String) {
    println("ERROR", message.magenta());
  }

  public static function shell(message : String) {
    println("CMD", message.magenta());
  }

  static function println(prefix : String, message : String) {
    Sys.println('${prefix.blue()}: ${message}');
  }
}
