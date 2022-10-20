module Steps
  module Client
    class BenefitCheckResultForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      attribute :passporting_benefit, :value_object, source: YesNoAnswer
      attr_accessor :confirm_benefit_check_result

      has_one_association :applicant

      validate :confirm_benefit_check_result_if_required

      def benefit_check_result
        BenefitCheckService.call(crime_application)
      end

      def choices
        YesNoAnswer.values
      end

      private

      def persist!
        applicant.update(
          passporting_benefit: passporting_benefit_answer
        )
      end

      def passporting_benefit_answer
        return nil if confirm_benefit_check_result&.downcase == 'no'

        benefit_check_result[:benefit_checker_status].casecmp('yes').zero?
      end

      def confirm_benefit_check_result_if_required
        return true if benefit_check_result[:benefit_checker_status].casecmp('yes').zero?

        return true if choices.map(&:value).include? confirm_benefit_check_result&.downcase&.to_sym

        errors.add(:confirm_benefit_check_result, :inclusion)
      end
    end
  end
end
