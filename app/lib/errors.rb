module Errors
  class InvalidSession < StandardError; end
  class ApplicationCannotReceivePse < StandardError; end
  class NotFound < StandardError; end
  class ApplicationNotFound < NotFound; end
  class SavingNotFound < NotFound; end
  class InvestmentNotFound < NotFound; end
  class NationalSavingsCertificateNotFound < NotFound; end
  class PropertyNotFound < NotFound; end
end
