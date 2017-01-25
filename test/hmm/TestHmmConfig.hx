package hmm;

import utest.Assert;

import thx.Either;
using thx.Eithers;

import hmm.HmmConfig;
import hmm.LibraryConfig;

class TestHmmConfig {
  public function new() {}

  public function testDeserialize_Empty_Failure() {
    Assert.isTrue(HmmConfigs.deserialize({}).either.isLeft());
  }

  public function testDeserialize_Success() {
    var actual = HmmConfigs.deserialize({
      dependencies: ([
        {
          type: "haxelib",
          name: "lib1"
        },
        {
          type: "haxelib",
          name: "lib2",
          version: ""
        },
        {
          type: "haxelib",
          name: "lib3",
          version: " "
        },
        {
          type: "haxelib",
          name: "lib4",
          version: "1.0.0"
        },
        {
          type: "git",
          name: "lib5",
          url: "url5"
        },
        {
          type: "git",
          name: "lib6",
          url: "url6",
          ref: "ref6"
        },
        {
          type: "git",
          name: "lib7",
          url: "url7",
          ref: "ref7",
          dir: "dir7"
        },
        {
          type: "git",
          name: "lib8",
          url: "url8",
          ref: "",
          dir: ""
        },
        {
          type: "git",
          name: "lib9",
          url: "url9",
          ref: "  ",
          dir: "  "
        }
      ] : Array<Dynamic>)
    });
    //trace(actual);
    var expected = Right({
      dependencies: [
        Haxelib("lib1", None),
        Haxelib("lib2", None),
        Haxelib("lib3", None),
        Haxelib("lib4", Some("1.0.0")),
        Git("lib5", "url5", None, None),
        Git("lib6", "url6", Some("ref6"), None),
        Git("lib7", "url7", Some("ref7"), Some("dir7")),
        Git("lib8", "url8", None, None),
        Git("lib9", "url9", None, None),
      ]
    });
    Assert.same(expected, actual);
  }
}
