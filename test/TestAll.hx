import utest.Assert;
import utest.ui.Report;
import utest.Runner;

class TestAll {
  public static function main() {
    var runner = new Runner();
    runner.addCase(new hmm.TestHmmConfig());
    runner.addCase(new hmm.utils.TestArrays());
    Report.create(runner);
    runner.run();
  }
}
