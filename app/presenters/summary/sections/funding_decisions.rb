module Summary
  module Sections
    class FundingDecisions < Sections::BaseSection
      def heading
        :funding_decisions
      end

      def show?
        return false unless FeatureFlags.show_funding_decisions.enabled?

        crime_application.status == ApplicationStatus::SUBMITTED && funding_decisions.any? && super
      end

      def answers
        Summary::Components::FundingDecision.with_collection(funding_decisions, show_actions: false)
      end

      def list?
        true
      end

      private

      def funding_decisions
        @funding_decisions ||= crime_application.decisions
      end
    end
  end
end
