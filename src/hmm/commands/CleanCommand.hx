package hmm.commands;

import hmm.utils.Shell;
import mcli.CommandLine;

class CleanCommand extends CommandLine {
  public function runDefault() {
    Shell.checkWorkingDirectory();
    Shell.haxelibRemoveRepoIfExists();
  }
}
