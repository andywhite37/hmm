package hmm.utils;

using hmm.utils.AnsiColors;

class Log {
  public static function println(message : String) : Void {
    Sys.println(message);
  }

  public static function debug(message : String) : Void {
    println(message.blue());
  }

  public static function info(message : String) : Void {
    println(message.green());
  }

  public static function warning(message : String) : Void {
    println(message.magenta());
  }

  public static function error(message : String) : Void {
    println(message.red());
  }

  public static function shell(message : String) : Void {
    println(message.yellow());
  }
}
