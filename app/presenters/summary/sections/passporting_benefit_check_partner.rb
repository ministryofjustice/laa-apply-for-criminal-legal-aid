module Summary
  module Sections
    class PassportingBenefitCheckPartner < Sections::BaseSection
      include TypeOfMeansAssessment
      def show?
        client_has_partner?
      end

      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      def answers
        answers = []

        if partner.benefit_type
          answers.push(Components::ValueAnswer.new(
                         :passporting_benefit, partner.benefit_type
                       ))
        end

        if jsa?
          answers.push(Components::DateAnswer.new(
                         :last_jsa_appointment_date, partner.last_jsa_appointment_date
                       ))
        end

        if benefit_check_status
          answers.push(Components::ValueAnswer.new(
                         :passporting_benefit_check_outcome, benefit_check_status
                       ))

          if partner.confirm_details
            answers.push(Components::ValueAnswer.new(
                           :confirmed_client_details, partner.confirm_details
                         ))
          end

          if partner.has_benefit_evidence
            answers.push(Components::ValueAnswer.new(
                           :has_benefit_evidence, partner.has_benefit_evidence
                         ))
          end
        end

        answers.select(&:show?)
        answers
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

      private

      def partner
        @partner ||= crime_application.partner
      end

      def benefit_check_status
        partner.benefit_check_status
      end

      def client_has_partner?
        applicant.has_partner == 'yes'
      end

      def jsa?
        partner.benefit_type == 'jsa'
      end
    end
  end
end
