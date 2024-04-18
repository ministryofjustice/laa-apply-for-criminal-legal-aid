module CapitalAssessment
  class AnswersValidator < ActiveModel::Validator
    def validate(record)
      record.errors.add :base, :incomplete_records if any_incomplete_records?(record)
    end

    private

    def any_incomplete_records?(capital)
      incomplete?(capital.properties) ||
        incomplete?(capital.savings) ||
        incomplete?(capital.investments) ||
        incomplete?(capital.national_savings_certificates) ||
        incomplete?(capital.national_savings_certificates)
    end

    def incomplete?(records)
      records.any? { |p| !p.complete? }
    end
  end
end
