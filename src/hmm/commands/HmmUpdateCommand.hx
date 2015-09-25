package hmm.commands;

import hmm.utils.Shell;

class HmmUpdateCommand implements ICommand {
  public var type(default, null) = "hmm-update";

  public function new() {
  }

  public function run(args : Array<String>) {
    Shell.updateHmm();
  }

  public function getUsage() {
    return 'updates the hmm tool';
  }
}
