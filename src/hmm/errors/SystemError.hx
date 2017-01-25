package hmm.errors;

import thx.Error;

class SystemError extends Error {
  public var statusCode(default, null) : Int;

  public function new(message : String, statusCode : Int) {
    super(message);
    this.statusCode = statusCode;
  }
}
