module IncomeAssessment
  class AnswersValidator
    include TypeOfMeansAssessment

    def initialize(record)
      @record = record
    end

    attr_reader :record

    delegate :errors, to: :record

    def validate # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      errors.add(:employment_status, :incomplete) unless employment_status_complete?

      errors.add(:income_before_tax, :incomplete) unless income_before_tax_complete?

      errors.add(:frozen_income_savings_assets, :incomplete) unless frozen_income_savings_assets_complete?

      errors.add(:income_payments, :incomplete) unless income_payments_complete?

      errors.add(:income_benefits, :incomplete) unless income_benefits_complete?

      errors.add(:dependants, :incomplete) unless dependants_complete?

      errors.add(:manage_without_income, :incomplete) unless manage_without_income_complete?

      errors.add(:base, :incomplete_records) if errors.present?
    end

    def employment_status_complete?
      record.employment_status.present?
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

      record.income_payments.present? && record.income_payments.all?(&:complete?)
    end

    def income_benefits_complete?
      return true if record.has_no_income_benefits == 'yes'

      record.income_benefits.present? && record.income_benefits.all?(&:complete?)
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

    delegate :crime_application, to: :record
  end
end