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
      return true if record.cifc?

      return true if kase.appeal_financial_circumstances_changed == 'yes' && kase.appeal_with_changes_details.present?

      record.appeal_no_changes?
    end

    def applicable?
      return false if record.non_means_tested?

      kase&.case_type.present? && CaseType.new(kase.case_type).appeal?
    end

    private

    def general_details_complete?
      kase.appeal_lodged_date.present? && kase.appeal_original_app_submitted.present?
    end
  end
end
