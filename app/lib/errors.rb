module Errors
  class InvalidSession < StandardError; end
  class ApplicationNotFound < StandardError; end
  class SavingNotFound < StandardError; end
  class PropertyNotFound < StandardError; end
  class ApplicationCannotReceivePse < StandardError; end
end
