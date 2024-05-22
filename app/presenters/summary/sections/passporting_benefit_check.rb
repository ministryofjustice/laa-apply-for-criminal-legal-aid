module Summary
  module Sections
    class PassportingBenefitCheck < Sections::BaseSection
      include TypeOfMeansAssessment
      def show?
        benefit_selected? && super
      end

      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      def answers
        answers = [
          Components::ValueAnswer.new(
            :passporting_benefit, applicant.benefit_type
          )
        ]

        if jsa?
          answers.push(Components::DateAnswer.new(
                         :last_jsa_appointment_date, applicant.last_jsa_appointment_date,
                         show: jsa?
                       ))
        end

        if benefit_check_result_known?
          answers.push(Components::ValueAnswer.new(
                         :passporting_benefit_check_outcome, benefit_check_result
                       ))

          if applicant.confirm_details
            answers.push(Components::ValueAnswer.new(
                           :confirmed_client_details, applicant.confirm_details
                         ))
          end

          if applicant.has_benefit_evidence
            answers.push(Components::ValueAnswer.new(
                           :has_benefit_evidence, applicant.has_benefit_evidence
                         ))
          end
        end

        answers.select(&:show?)
        answers
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

      def change_path
        edit_steps_dwp_benefit_type_path
      end

      private

      def applicant
        @applicant ||= crime_application.applicant
      end

      def benefit_check_result_known?
        !benefit_check_attributes_not_set? || benefit_check_passported?
      end

      # If all the benefit check attributes are nil and there is a benefit type
      # then we can infer that the application was submitted before these values were being saved
      # Therefore, we can use this to determine whether the benefit check rows should be displayed
      def benefit_check_attributes_not_set? # rubocop:disable Metrics/AbcSize
        applicant.benefit_check_result.nil? && applicant.has_benefit_evidence.nil? &&
          applicant.will_enter_nino.nil? && applicant.confirm_details.nil? &&
          crime_application.confirm_dwp_result.nil? && applicant.benefit_type != 'none'
      end

      # Rules out applications where the passporting benefit check was not applicable e.g. appeal no changes
      def benefit_selected?
        applicant.benefit_type.present?
      end

      def jsa?
        applicant.benefit_type == 'jsa'
      end

      # For resubmitted applications, we can infer true value if means passport is on benefit check and show the section
      def benefit_check_passported?
        crime_application.means_passport.include?(MeansPassportType::ON_BENEFIT_CHECK.to_s)
      end

      def benefit_check_result # rubocop:disable Metrics/CyclomaticComplexity
        return 'no_check_no_nino' if nino_forthcoming?
        return 'undetermined' if benefit_evidence_forthcoming?
        return 'no_record_found' if means_assessment_as_benefit_evidence?
        return 'no_check_required' if applicant.benefit_type == 'none'
        return 'checker_unavailable' if applicant.benefit_check_result.nil? && applicant.has_benefit_evidence.present?
        return true if benefit_check_passported?

        applicant.benefit_check_result
      end
    end
  end
end
