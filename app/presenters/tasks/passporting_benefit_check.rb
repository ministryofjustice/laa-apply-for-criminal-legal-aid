module Tasks
  class PassportingBenefitCheck < BaseTask
    delegate :partner, to: :crime_application

    def path
      return edit_steps_dwp_partner_benefit_type_path if applicant.arc.present? && partner.present?

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
