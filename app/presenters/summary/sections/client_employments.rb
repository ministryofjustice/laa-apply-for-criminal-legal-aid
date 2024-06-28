module Summary
  module Sections
    class ClientEmployments < Sections::BaseSection
      include TypeOfMeansAssessment

      def show?
        return false if employments.empty?
        #return false unless requires_full_means_assessment?

        income.employment_status.include?('employed')
      end

      def answers
        return [] if employments.empty?

        Components::Employment.with_collection(
          employments, show_actions: editable?, show_record_actions: headless?
        )
      end

      def list?
        return false if employments.empty?

        true
      end

      private

      def employments
        @employments ||= crime_application.client_employments
      end

      # def single_employment_income?(income)
      #   income.employment_status.include?(EmploymentStatus::EMPLOYED.to_s) &&
      #     income.income_above_threshold == YesNoAnswer::NO.to_s &&
      #     income.has_frozen_income_or_assets == YesNoAnswer::NO.to_s &&
      #     income.client_owns_property == YesNoAnswer::NO.to_s &&
      #     income.has_savings == YesNoAnswer::NO.to_s
      # end
    end
  end
end
