module CapitalAssessment
  class AnswersValidator
    include TypeOfMeansAssessment

    def initialize(record=nil, crime_application: nil)
      @record = record || crime_application.capital
      @crime_application = crime_application
    end

    attr_reader :record, :crime_application

    delegate :errors, to: :record

    def applicable?
      requires_full_means_assessment?
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
        errors.add :investment_type, :blank unless investment_type_complete?
        errors.add :investments, :incomplete_records unless investments_complete?
        errors.add :has_national_savings_certificates, :blank unless has_national_savings_certificates_complete?
        errors.add :national_savings_certificates, :incomplete_records unless national_savings_certificates_complete?
      end

      errors.add :trust_fund, :blank unless trust_fund_complete?
      errors.add :frozen_income_savings_assets_capital, :blank unless frozen_income_savings_assets_complete?

      errors.add(:base, :incomplete_records) if errors.present?
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

    def frozen_income_savings_assets_complete?
      record.has_frozen_income_or_assets.present? || income&.has_frozen_income_or_assets.present?
    end
  end
end
