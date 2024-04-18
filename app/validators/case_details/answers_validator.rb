module CaseDetails
  class AnswersValidator < ActiveModel::Validator
    def validate(record)
      record.errors.add :base, :incomplete_records unless record.complete?
    end
  end
end
