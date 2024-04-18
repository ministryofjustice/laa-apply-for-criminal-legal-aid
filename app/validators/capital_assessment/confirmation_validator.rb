module CapitalAssessment
  class ConfirmationValidator
    def initialize(record)
      @record = record
    end

    attr_reader :record

    def validate
      record.errors.add :has_no_other_assets, :blank unless confirmed?
    end

    def confirmed?
      record.has_no_other_assets == YesNoAnswer::YES.to_s
    end
  end
end
