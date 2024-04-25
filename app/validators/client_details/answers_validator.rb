module ClientDetails
  class AnswersValidator
    def initialize(record)
      @record = record
    end

    attr_reader :record

    delegate :errors, :applicant, :kase, :crime_application, to: :record

    def validate
    end

    def valid?
      validate
      errors.any?
    end

    def address_complete?
      case applicant.correspondence_address_type
      when CorrespondenceType::HOME_ADDRESS.to_s
        applicant.home_address?
      when CorrespondenceType::OTHER_ADDRESS.to_s
        applicant.correspondence_address?
      when CorrespondenceType::PROVIDERS_OFFICE_ADDRESS.to_s
        true
      else
        false
      end
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
