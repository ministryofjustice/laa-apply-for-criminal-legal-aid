module Errors
  class InvalidSession < StandardError; end
  class ApplicationNotFound < StandardError; end
  class ApplicationCannotReceivePse < StandardError; end
end
