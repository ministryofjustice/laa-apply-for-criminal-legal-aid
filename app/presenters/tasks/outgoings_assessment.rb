module Tasks
  class OutgoingsAssessment < BaseTask
    include TypeOfMeansAssessment

    def path
      edit_steps_outgoings_housing_payment_type_path
    end

    def not_applicable?
      applicant.present? && super
    end

    def can_start?
      fulfilled?(IncomeAssessment)
    end

    def in_progress?
      outgoings.present?
    end

    private

    def validator
      @validator ||= ::OutgoingsAssessment::AnswersValidator.new(crime_application)
    end
  end
end
