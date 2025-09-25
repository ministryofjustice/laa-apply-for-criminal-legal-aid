module Errors
  class ApplicationCannotReceivePse < StandardError; end
  class CannotYetDetermineFullMeans < StandardError; end
  class ContingentLiability < StandardError; end
  class DateOfBirthPending < StandardError; end
  class InvalidRuleset < StandardError; end
  class InvalidSession < StandardError; end
  class UnsupportedPredicate < StandardError; end
  class UnscopedDatastoreQuery < StandardError; end

  class NotFound < StandardError; end
  class ApplicationNotFound < NotFound; end
  class BusinessNotFound < NotFound; end
  class DocumentUnavailable < NotFound; end
  class EmploymentNotFound < NotFound; end
  class InvestmentNotFound < NotFound; end
  class NationalSavingsCertificateNotFound < NotFound; end
  class PropertyNotFound < NotFound; end
  class SavingNotFound < NotFound; end
  class SubjectNotFound < NotFound; end
  class OfficeNotFound < NotFound; end
end
