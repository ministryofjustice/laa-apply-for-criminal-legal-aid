module CapitalAssessment
  class AnswersValidator < BaseAnswerValidator
    include TypeOfMeansAssessment

    def applicable?
      extent_of_means_assessment_determined? && requires_full_means_assessment?
    end

    def complete?
      validate
      errors.empty?
    end

    def validate # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/MethodLength
      if requires_full_capital?
        errors.add :property_type, :blank unless property_type_complete?
        errors.add :properties, :incomplete_records unless properties_complete?
        errors.add :saving_type, :blank unless saving_type_complete?
        errors.add :savings, :incomplete_records unless savings_complete?
        errors.add :premium_bonds, :blank unless premium_bonds_complete?
        errors.add :partner_premium_bonds, :blank unless partner_premium_bonds_complete?
        errors.add :has_national_savings_certificates, :blank unless has_national_savings_certificates_complete?
        errors.add :national_savings_certificates, :incomplete_records unless national_savings_certificates_complete?
        errors.add :investment_type, :blank unless investment_type_complete?
        errors.add :investments, :incomplete_records unless investments_complete?
        errors.add :usual_property_details, :blank unless usual_property_details_complete?
      end

      errors.add :trust_fund, :blank unless trust_fund_complete?
      errors.add :partner_trust_fund, :blank unless partner_trust_fund_complete?
      errors.add :frozen_income_savings_assets_capital, :blank unless frozen_income_savings_assets_complete?

      errors.presence&.add(:base, :incomplete_records)
    end

    def property_type_complete?
      return true if record.has_no_properties == 'yes'

      !record.properties.empty?
    end

    def properties_complete?
      return true if record.has_no_properties == 'yes'

      record.properties.present? && record.properties.all?(&:complete?)
    end

    def saving_type_complete?
      return true if record.has_no_savings == 'yes'

      !record.savings.empty?
    end

    def savings_complete?
      return true if record.has_no_savings == 'yes'

      record.savings.present? && record.savings.all?(&:complete?)
    end

    def premium_bonds_complete?
      return true if record.has_premium_bonds == 'no'
      return false unless record.has_premium_bonds == 'yes'

      record.premium_bonds_holder_number.present? && record.premium_bonds_total_value.present?
    end

    def partner_premium_bonds_complete?
      return true unless include_partner_in_means_assessment?
      return true if record.partner_has_premium_bonds == 'no'
      return false unless record.partner_has_premium_bonds == 'yes'

      record.partner_premium_bonds_holder_number.present? && record.partner_premium_bonds_total_value.present?
    end

    def investment_type_complete?
      return true if record.has_no_investments == 'yes'

      !record.investments.empty?
    end

    def investments_complete?
      return true if record.has_no_investments == 'yes'

      record.investments.present? & record.investments.all?(&:complete?)
    end

    def has_national_savings_certificates_complete?
      record.has_national_savings_certificates.present?
    end

    def national_savings_certificates_complete?
      return true if record.has_national_savings_certificates == 'no'

      record.national_savings_certificates.present? && record.national_savings_certificates.all?(&:complete?)
    end

    def trust_fund_complete?
      return true if record.will_benefit_from_trust_fund == 'no'
      return false unless record.will_benefit_from_trust_fund == 'yes'

      record.trust_fund_amount_held.present? && record.trust_fund_yearly_dividend.present?
    end

    def partner_trust_fund_complete?
      return true unless include_partner_in_means_assessment?
      return true if record.partner_will_benefit_from_trust_fund == 'no'
      return false unless record.partner_will_benefit_from_trust_fund == 'yes'

      record.partner_trust_fund_amount_held.present? && record.partner_trust_fund_yearly_dividend.present?
    end

    def frozen_income_savings_assets_complete?
      record.has_frozen_income_or_assets.present? || income&.has_frozen_income_or_assets.present?
    end

    def usual_property_details_complete?
      !record.usual_property_details_required?
    end
  end
end
