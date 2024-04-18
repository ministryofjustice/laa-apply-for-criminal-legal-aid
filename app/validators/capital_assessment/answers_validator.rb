module CapitalAssessment
  class AnswersValidator
    def initialize(record)
      @record = record
    end

    attr_reader :record

    def validate
      record.errors.add :base, :incomplete_records unless all_complete?
    end

    def all_complete? # rubocop:disable Metrics/CyclomaticComplexity
      record.properties.all?(&:complete?) &&
        record.savings.all?(&:complete?) &&
        record.investments.all?(&:complete?) &&
        record.national_savings_certificates.all?(&:complete?)
    end
  end
end
