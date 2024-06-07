module Tasks
  class PassportingBenefitCheck < BaseTask
    def path
      edit_steps_dwp_benefit_type_path
    end

    def can_start?
      fulfilled?(ClientDetails) && fulfilled?(PartnerDetails)
    end

    def in_progress?
      fulfilled?(ClientDetails)
    end

    private

    def validator
      @validator ||= ::PassportingBenefitCheck::AnswersValidator.new(
        crime_application
      )
    end
  end
end
