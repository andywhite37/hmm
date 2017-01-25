package hmm.utils;

class Args {
  public static function hasAny(args : Array<String>, testItems : Array<String>) : Bool {
    return Arrays.containsAny(args, testItems, function(a, b) return a == b);
  }

  public static function removeAll(args : Array<String>, items : Array<String>) : Array<String> {
    return Arrays.removeAll(args, items);
  }
}
