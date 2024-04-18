module CapitalAssessment
  class ConfirmationValidator < ActiveModel::Validator
    def validate(record)
      record.errors.add :has_no_other_assets, :blank unless confirmed?(record)
    end

    private

    def confirmed?(record)
      record.has_no_other_assets == YesNoAnswer::YES.to_s
    end
  end
end
