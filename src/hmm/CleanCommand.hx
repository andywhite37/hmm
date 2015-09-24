package hmm;

import mcli.CommandLine;

class CleanCommand extends CommandLine {
  public function runDefault() {
    Command.haxelibRemoveRepo();
  }
}
