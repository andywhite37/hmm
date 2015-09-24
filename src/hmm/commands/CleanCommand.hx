package hmm.commands;

import hmm.utils.Shell;

class CleanCommand implements ICommand {
  public function new() {
  }

  public function run() {
    Shell.checkWorkingDirectory();
    Shell.haxelibRemoveRepoIfExists();
  }
}
