module Errors
  class InvalidSession < StandardError; end
  class ApplicationCannotReceivePse < StandardError; end
  class DateOfBirthPending < StandardError; end
  class CannotYetDetermineFullMeans < StandardError; end
  class NotFound < StandardError; end
  class ApplicationNotFound < NotFound; end
  class SavingNotFound < NotFound; end
  class InvestmentNotFound < NotFound; end
  class NationalSavingsCertificateNotFound < NotFound; end
  class PropertyNotFound < NotFound; end
  class UnsupportedPredicate < StandardError; end
  class InvalidRuleset < StandardError; end
  class DocumentUnavailable < NotFound; end
  class EmploymentNotFound < NotFound; end
  class SubjectNotFound < NotFound; end
  class BusinessNotFound < NotFound; end
end
