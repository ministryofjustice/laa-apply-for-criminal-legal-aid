module Evidence
  module Rules
    class ShareIsa < Rule
      include Evidence::RuleDsl

      key :capital_share_isa_26
      group :capital

      client do |crime_application|
        crime_application.capital&.client_share_isa_investments.present?
      end

      partner do |crime_application|
        crime_application.capital&.partner_share_isa_investments.present?
      end
    end
  end
end
