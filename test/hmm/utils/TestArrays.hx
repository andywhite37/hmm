package hmm.utils;

import utest.Assert;

using hmm.utils.Arrays;

class TestArrays {
  public function new() {}

  public function testAny() {
    Assert.isTrue([1, 2, 3].any(function(a) return a == 2));
    Assert.isTrue([1, 2, 3].any(function(a) return a > 2));
    Assert.isFalse([1, 2, 3].any(function(a) return a == 4));
  }

  public function testAll() {
    Assert.isTrue([1, 2, 3].all(function(a) return a > 0));
    Assert.isFalse([1, 2, 3].all(function(a) return a > 1));
  }

  public function testContains() {
    Assert.isTrue([1, 2, 3].contains(1));
    Assert.isTrue([1, 2, 3].contains(2));
    Assert.isFalse([1, 2, 3].contains(4));
  }

  public function testContainsAny() {
    Assert.isTrue([1, 2, 3].containsAny([1, 2]));
    Assert.isTrue([1, 2, 3].containsAny([3, 4]));
    Assert.isFalse([1, 2, 3].containsAny([5, 6]));
  }

  public function testRemoveAll() {
    Assert.same([1, 2, 3], [0, 1, 2, 3, 4, 5].removeAll([0, 4, 5]));
    Assert.same([], [0, 1, 2, 3, 4, 5].removeAll([5, 4, 3, 2, 1, 0]));
    Assert.same([0, 1, 2, 3, 4, 5], [0, 1, 2, 3, 4, 5].removeAll([-1, 7]));
  }
}
