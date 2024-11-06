module PersonCapitalAssets
  extend ActiveSupport::Concern

  %i[savings investments national_savings_certificates].each do |assets|
    define_method(:"client_#{assets}") do
      public_send(assets).select do |asset|
        next if asset.ownership_type.blank?

        ownership_type = OwnershipType.new(asset.ownership_type)
        ownership_type.applicant? || ownership_type.applicant_and_partner?
      end
    end

    define_method(:"partner_#{assets}") do
      public_send(assets).select do |asset|
        next if asset.ownership_type.blank?

        ownership_type = OwnershipType.new(asset.ownership_type)
        ownership_type.partner? || ownership_type.applicant_and_partner?
      end
    end
  end

  SavingType::VALUES.each do |saving_type|
    define_method(:"client_#{saving_type}_savings") do
      client_savings.select do |saving|
        SavingType.new(saving.saving_type) == saving_type
      end
    end

    define_method(:"partner_#{saving_type}_savings") do
      partner_savings.select do |saving|
        SavingType.new(saving.saving_type) == saving_type
      end
    end
  end

  InvestmentType::VALUES.each do |investment_type|
    define_method(:"client_#{investment_type}_investments") do
      client_investments.select do |investment|
        InvestmentType.new(investment.investment_type) == investment_type
      end
    end

    define_method(:"partner_#{investment_type}_investments") do
      partner_investments.select do |investment|
        InvestmentType.new(investment.investment_type) == investment_type
      end
    end
  end
end
