module CapitalAssessment
  class AnswersValidator
    def initialize(record)
      @record = record
    end

    attr_reader :record

    delegate :errors, to: :record

    def validate # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      errors.add :property_type, :blank unless property_type_complete?

      errors.add :properties, :incomplete_records unless properties_complete?

      errors.add :saving_type, :blank unless saving_type_complete?

      errors.add :savings, :incomplete_records unless savings_complete?

      errors.add :investment_type, :blank unless investment_type_complete?

      errors.add :investments, :incomplete_records unless investments_complete?

      errors.add :has_national_savings_certificates, :blank unless has_national_savings_certificates_complete?

      errors.add :national_savings_certificates, :incomplete_records unless national_savings_certificates_complete?

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
  end
end
