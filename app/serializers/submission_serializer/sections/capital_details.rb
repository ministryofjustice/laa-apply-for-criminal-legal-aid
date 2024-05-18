module SubmissionSerializer
  module Sections
    class CapitalDetails < Sections::BaseSection
      def to_builder # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        Jbuilder.new do |json|
          next unless capital && requires_full_means_assessment?

          if requires_full_capital?
            json.has_premium_bonds capital.has_premium_bonds
            json.premium_bonds_total_value capital.premium_bonds_total_value_before_type_cast
            json.premium_bonds_holder_number capital.premium_bonds_holder_number
            json.has_no_savings capital.has_no_savings
            json.savings Definitions::Saving.generate(capital.savings)
            json.has_no_investments capital.has_no_investments
            json.investments Definitions::Investment.generate(capital.investments)
            json.has_national_savings_certificates capital.has_national_savings_certificates
            json.national_savings_certificates Definitions::NationalSavingsCertificate.generate(
              capital.national_savings_certificates
            )
            json.has_no_properties capital.has_no_properties
            json.properties Definitions::Property.generate(capital.properties)
            json.has_no_other_assets capital.has_no_other_assets
          end

          json.will_benefit_from_trust_fund capital.will_benefit_from_trust_fund
          json.trust_fund_amount_held capital.trust_fund_amount_held_before_type_cast
          json.trust_fund_yearly_dividend capital.trust_fund_yearly_dividend_before_type_cast

          unless income.has_frozen_income_or_assets.present? || capital.has_frozen_income_or_assets.blank?
            json.has_frozen_income_or_assets capital.has_frozen_income_or_assets
          end
        end
      end
    end
  end
end