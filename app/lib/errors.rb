module Errors
  class InvalidSession < StandardError; end
  class ApplicationNotFound < StandardError; end
  class ApplicationNotAssessed < StandardError; end
  class ApplicationNotInitial < StandardError; end
end
