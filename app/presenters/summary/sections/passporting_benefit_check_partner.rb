module Summary
  module Sections
    class PassportingBenefitCheckPartner < Sections::PassportingBenefitCheck
      def show?
        include_partner_in_means_assessment? && partner.arc.nil?
      end

      def change_path
        nil
      end

      private

      def person
        @person ||= crime_application.partner
      end

      def subject_type
        SubjectType.new(:partner)
      end
    end
  end
end
