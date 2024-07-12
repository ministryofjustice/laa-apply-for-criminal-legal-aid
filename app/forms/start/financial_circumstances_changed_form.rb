module Start
  class FinancialCircumstancesChangedForm < Steps::BaseFormObject
    attribute :has_financial_circumstances_changed, :value_object, source: YesNoAnswer
    validates :has_financial_circumstances_changed, inclusion: { in: :choices }

    def self.build(crime_application)
      new(crime_application:)
    end

    def choices
      [YesNoAnswer::NO, YesNoAnswer::YES]
    end

    private

    def persist!
      true
    end
  end
end
