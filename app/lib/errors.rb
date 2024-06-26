module Errors
  class InvalidSession < StandardError; end
  class ApplicationCannotReceivePse < StandardError; end
  class NotFound < StandardError; end
  class ApplicationNotFound < NotFound; end
  class SavingNotFound < NotFound; end
  class InvestmentNotFound < NotFound; end
  class NationalSavingsCertificateNotFound < NotFound; end
  class PropertyNotFound < NotFound; end
  class UnsupportedPredicate < StandardError; end
  class InvalidRuleset < StandardError; end
  class DocumentUnavailable < NotFound; end
  class DateOfBirthPending < StandardError; end
  class EmploymentNotFound < NotFound; end
  class SubjectNotFound < NotFound; end
  class CannotYetDetermineFullMeans < NotFound; end
end
