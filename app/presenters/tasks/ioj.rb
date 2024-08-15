module Tasks
  class Ioj < BaseTask
    def path
      if crime_application.ioj_passported?
        edit_steps_case_ioj_passport_path
      else
        edit_steps_case_ioj_path
      end
    end

    def not_applicable?
      return true if crime_application.cifc?

      false
    end

    def can_start?
      fulfilled?(CaseDetails)
    end

    def in_progress?
      crime_application.ioj_passport.any? || ioj.present?
    end

    def completed?
      return true if crime_application.ioj_passported?

      ioj.present? && ioj.types.any? && ioj_attributes_present?
    end

    def ioj_attributes_present?
      required_attributes = ioj.types.map { |type| "#{type}_justification" }
      ioj.values_at(*required_attributes).all?(&:present?)
    end
  end
end
