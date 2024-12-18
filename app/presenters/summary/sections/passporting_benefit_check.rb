module Summary
  module Sections
    class PassportingBenefitCheck < Sections::BaseSection
      include TypeOfMeansAssessment
      include HasDynamicSubject

      def show?
        benefit_selected? && super
      end

      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      def answers
        answers = []

        if person.benefit_type
          answers.push(Components::ValueAnswer.new(
                         :passporting_benefit, person.benefit_type
                       ))
        end

        if jsa?
          answers.push(Components::DateAnswer.new(
                         :last_jsa_appointment_date, person.last_jsa_appointment_date,
                         show: jsa?
                       ))
        end

        if benefit_check_status
          answers.push(Components::ValueAnswer.new(
                         :passporting_benefit_check_outcome, benefit_check_status
                       ))

          if person.confirm_details
            answers.push(Components::ValueAnswer.new(
                           :confirmed_details, person.confirm_details
                         ))
          end

          if person.has_benefit_evidence
            answers.push(Components::ValueAnswer.new(
                           :has_benefit_evidence, person.has_benefit_evidence
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

      def person
        @person ||= crime_application.applicant
      end

      # If the benefit_check_status is nil we can infer
      # that the application was submitted before the benefit check result data was being saved
      # Therefore, we can use this to determine whether the benefit check rows should be displayed
      def benefit_check_status
        person.benefit_check_status
      end

      # Rules out applications where the passporting benefit check was not applicable e.g. appeal no changes
      def benefit_selected?
        person.benefit_type.present?
      end

      def jsa?
        person.benefit_type == 'jsa'
      end
    end
  end
end
