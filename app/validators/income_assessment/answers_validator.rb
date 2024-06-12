module IncomeAssessment
  class AnswersValidator < BaseAnswerValidator
    include TypeOfMeansAssessment

    def applicable?
      requires_means_assessment?
    end

    def complete?
      validate
      errors.empty?
    end

    def validate # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      return unless applicable?

      EmploymentDetails::AnswersValidator.new(record).validate

      errors.add(:income_before_tax, :incomplete) unless income_before_tax_complete?
      errors.add(:frozen_income_savings_assets, :incomplete) unless frozen_income_savings_assets_complete?
      errors.add(:income_payments, :incomplete) unless income_payments_complete?
      errors.add(:income_benefits, :incomplete) unless income_benefits_complete?
      errors.add(:partner_income_payments, :incomplete) unless partner_income_payments_complete?
      errors.add(:partner_income_benefits, :incomplete) unless partner_income_benefits_complete?
      errors.add(:dependants, :incomplete) unless dependants_complete?
      errors.add(:manage_without_income, :incomplete) unless manage_without_income_complete?
      errors.add(:base, :incomplete_records) if errors.present?
    end

    def income_before_tax_complete?
      record.income_above_threshold.present?
    end

    def frozen_income_savings_assets_complete?
      return true unless income_below_threshold?

      record.has_frozen_income_or_assets.present?
    end

    def income_payments_complete?
      return true if record.has_no_income_payments == 'yes'

      record.income_payments.for_client.present? && record.income_payments.for_client.all?(&:complete?)
    end

    def partner_income_payments_complete?
      return true unless FeatureFlags.partner_journey.enabled?
      return true if crime_application.income.partner_has_no_income_payments.to_s == 'yes'

      # TODO: Determine rule for completeness
      # return true unless crime_application.include_partner_in_means_assessment?

      record.income_payments.for_partner.present? && record.income_payments.for_partner.all?(&:complete?)
    end

    def income_benefits_complete?
      return true if record.has_no_income_benefits == 'yes'

      record.income_benefits.for_client.present? && record.income_benefits.for_client.all?(&:complete?)
    end

    def partner_income_benefits_complete?
      return true unless FeatureFlags.partner_journey.enabled?
      return true if crime_application.income.partner_has_no_income_payments.to_s == 'yes'

      # TODO: Determine rule for completeness
      # return true unless crime_application.include_partner_in_means_assessment?

      record.income_benefits.for_partner.present? && record.income_benefits.for_partner.all?(&:complete?)
    end

    def dependants_complete?
      return true unless requires_full_means_assessment?
      return true if record.client_has_dependants == YesNoAnswer::NO.to_s

      record.client_has_dependants == YesNoAnswer::YES.to_s && record.dependants.present?
    end

    def manage_without_income_complete?
      return true if record.income_payments.present? || record.income_benefits.present?

      record.manage_without_income.present?
    end
  end
end
