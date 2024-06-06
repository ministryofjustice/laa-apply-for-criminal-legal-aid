module Tasks
  class PartnerDetails < BaseTask
    def path
      edit_steps_client_has_partner_path
    end

    def can_start?
      fulfilled?(ClientDetails)
    end

    def in_progress?
      crime_application.partner_detail.present?
    end

    private

    def validator
      @validator ||= ::PartnerDetails::AnswersValidator.new(
        record: crime_application.partner_detail,
        crime_application: crime_application
      )
    end
  end
end
