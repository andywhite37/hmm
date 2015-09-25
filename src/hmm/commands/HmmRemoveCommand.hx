package hmm.commands;

import hmm.utils.Shell;

class HmmRemoveCommand implements ICommand {
  public var type(default, null) = "hmm-remove";

  public function new() {
  }

  public function run(args : Array<String>) {
    Shell.removeHmm();
  }

  public function getUsage() {
    return 'removes the hmm tool';
  }
}
