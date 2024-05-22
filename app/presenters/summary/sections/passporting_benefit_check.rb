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

        answers.push(Components::ValueAnswer.new(
                       :passporting_benefit_check_outcome, benefit_check_outcome
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

      def benefit_selected?
        crime_application.applicant.benefit_type.present?
      end

      def jsa?
        crime_application.applicant.benefit_type == 'jsa'
      end

      def benefit_check_outcome
        return 'no_check_no_nino' if nino_forthcoming?
        return 'undetermined' if benefit_evidence_forthcoming?
        return 'no_record_found' if means_assessment_as_benefit_evidence?
        return 'no_check_required' if applicant.benefit_type == 'none'
        return 'checker_unavailable' if applicant.benefit_check_result.nil? && applicant.has_benefit_evidence.present?

        applicant.benefit_check_result
      end
    end
  end
end
