module AppealDetails
  class AnswersValidator
    include TypeOfMeansAssessment

    def initialize(record)
      @record = record
    end

    attr_reader :record

    delegate :errors, :kase, to: :record

    def validate
      return unless applicable?
      return if complete?

      errors.add(:appeal_details, :incomplete)
    end

    def complete?
      return false unless general_details_complete?
      return true if kase.appeal_original_app_submitted == 'no'
      return true if kase.appeal_financial_circumstances_changed == 'yes' && kase.appeal_with_changes_details.present?

      kase.appeal_financial_circumstances_changed == 'no' &&
        kase.values_at(:appeal_maat_id, :appeal_usn).any?(&:present?)
    end

    def applicable?
      kase&.case_type.present? && CaseType.new(kase.case_type).appeal?
    end

    private

    def general_details_complete?
      kase.appeal_lodged_date.present? && kase.appeal_original_app_submitted.present?
    end
  end
end
