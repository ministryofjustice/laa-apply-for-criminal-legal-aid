module Evidence
  module Rules
    class BankAccounts < Rule
      include Evidence::RuleDsl

      key :capital_bank_accounts_16
      group :capital

      client do |_crime_application, applicant|
        applicant.savings.bank.any? || applicant.joint_savings.bank.any?
      end

      partner do |crime_application, partner|
        MeansStatus.include_partner?(crime_application) &&
          (partner.savings.bank.any? || partner.joint_savings.bank.any?)
      end
    end
  end
end
