module OutgoingsAssessment
  class AnswersValidator < BaseAnswerValidator
    include TypeOfMeansAssessment

    def applicable?
      extent_of_means_assessment_determined? && requires_full_means_assessment?
    end

    def complete?
      validate
      errors.empty?
    end

    def validate # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      return unless applicable?

      errors.add(:housing_payment_type, :incomplete) unless housing_payment_type_complete?
      errors.add(:mortgage, :incomplete) unless mortgage_complete?
      errors.add(:rent, :incomplete) unless rent_complete?
      errors.add(:board_and_lodging, :incomplete) unless board_and_lodging_complete?
      errors.add(:council_tax, :incomplete) unless council_tax_complete?
      errors.add(:outgoings_payments, :incomplete) unless outgoings_payments_complete?
      errors.add(:income_tax_rate, :incomplete) unless income_tax_rate_complete?
      errors.add(:partner_income_tax_rate, :incomplete) unless partner_income_tax_rate_complete?
      errors.add(:outgoings_more_than, :incomplete) unless outgoings_more_than_income_complete?
      errors.presence&.add(:base, :incomplete_records)
    end

    def housing_payment_type_complete?
      record.housing_payment_type.present?
    end

    def mortgage_complete?
      return true unless record.housing_payment_type == HousingPaymentType::MORTGAGE.to_s
      return false if record.outgoings_payments.mortgage.nil?

      record.outgoings_payments.mortgage.complete?
    end

    def rent_complete?
      return true unless record.housing_payment_type == HousingPaymentType::RENT.to_s
      return false if record.outgoings_payments.rent.nil?

      record.outgoings_payments.rent.complete?
    end

    def board_and_lodging_complete?
      return true unless record.housing_payment_type == HousingPaymentType::BOARD_AND_LODGING.to_s
      return false if record.outgoings_payments.board_and_lodging.nil?

      record.outgoings_payments.board_and_lodging.complete?
    end

    def council_tax_complete?
      not_tax_types = [
        HousingPaymentType::NONE.to_s,
        HousingPaymentType::BOARD_AND_LODGING.to_s
      ]

      return true if not_tax_types.include?(record.housing_payment_type)
      return true if record.pays_council_tax == 'no'
      return false if record.outgoings_payments.council_tax.nil?

      record.outgoings_payments.council_tax&.complete?
    end

    def outgoings_payments_complete?
      return true if record.has_no_other_outgoings == 'yes'
      return false if record.other_payments.empty?

      record.other_payments.all?(&:complete?)
    end

    def income_tax_rate_complete?
      record.income_tax_rate_above_threshold.present?
    end

    def partner_income_tax_rate_complete?
      return true unless include_partner_in_means_assessment?

      record.partner_income_tax_rate_above_threshold.present?
    end

    def outgoings_more_than_income_complete?
      return false if record.outgoings_more_than_income.blank?
      return true if record.outgoings_more_than_income == 'no'

      record.how_manage.present?
    end
  end
end
