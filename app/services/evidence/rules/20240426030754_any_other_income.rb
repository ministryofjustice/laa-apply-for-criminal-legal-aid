module Evidence
  module Rules
    class AnyOtherIncome < Rule
      include Evidence::RuleDsl

      key :income_other_9
      group :income

      client do |_crime_application, applicant|
        OtherIncomeEvidenceRequired.for(applicant)
      end

      partner do |_crime_application, partner|
        partner.present? && OtherIncomeEvidenceRequired.for(partner)
      end
    end
  end

  class OtherIncomeEvidenceRequired
    def self.for(person)
      other_income = person.income_payment(IncomePaymentType::OTHER)
      other_income.present? && other_income.details.present?
    end
  end
end
