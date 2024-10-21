module Summary
  module Sections
    class PassportingBenefitCheckPartner < Sections::PassportingBenefitCheck
      def show?
        person.is_included_in_means_assessment && person.arc.nil?
      end

      def change_path
        nil
      end

      private

      def person
        @person ||= crime_application.partner
      end
    end
  end
end
