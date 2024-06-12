module Summary
  module Sections
    class PartnerEmploymentDetails < Sections::BaseSection
      def show?
        income.present? && income.partner_employment_status.present? && super
      end

      def answers
        [
          Components::ValueAnswer.new(
            # TODO: Handle array of partner_employment_statuses when designs for employed partner available
            :partner_employment_status, income.partner_employment_status.first,
            change_path: edit_steps_income_partner_employment_status_path
          )
        ].flatten.select(&:show?)
      end
    end
  end
end
