module Evidence
  module Rules
    class CashIsa < Rule
      include Evidence::RuleDsl

      key :capital_cash_isa_18
      group :capital

      client do |crime_application, applicant|
        applicant.savings(SavingType::CASH_ISA).any?
      end

      partner do |crime_application, partner|
        partner.present? && partner.savings(SavingType::CASH_ISA).any?
      end
    end
  end
end
