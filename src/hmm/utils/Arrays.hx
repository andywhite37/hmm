package hmm.utils;

class Arrays {
  public static function any<T>(arr : Array<T>, f : T -> Bool) : Bool {
    for (item in arr) {
      if (f(item)) return true;
    }
    return false;
  }

  public static function all<T>(arr : Array<T>, f : T -> Bool) : Bool {
    for (item in arr) {
      if (!f(item)) return false;
    }
    return true;
  }

  public static function contains<T>(arr : Array<T>, testItem : T, ?equals : T -> T -> Bool) : Bool {
    if (equals == null) equals = function(a, b) return a == b;
    for (item in arr) {
      if (equals(item, testItem)) return true;
    }
    return false;
  }

  public static function containsAny<T>(arr : Array<T>, testItems : Array<T>, ?equals : T -> T -> Bool) : Bool {
    if (equals == null) equals = function(a, b) return a == b;
    for (item in arr) {
      for (testItem in testItems) {
        if (equals(item, testItem)) return true;
      }
    }
    return false;
  }

  public static function removeAll<T>(arr : Array<T>, items : Array<T>, ?equals : T -> T -> Bool) : Array<T> {
    var result : Array<T> = [];
    for (item in arr) {
      if (!contains(items, item)) result.push(item);
    }
    return result;
  }
}
