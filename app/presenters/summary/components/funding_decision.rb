module Summary
  module Components
    class FundingDecision < BaseRecord
      private

      def answers # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
        [
          Components::FreeTextAnswer.new(
            :funding_decision_maat_id, funding_decision.maat_id.to_s
          ),
          Components::FreeTextAnswer.new(
            :funding_decision_case_number, funding_decision.case_id
          ),
          Components::ValueAnswer.new(
            :funding_decision_court_type, funding_decision.court_type
          ),
          Components::ValueAnswer.new(
            :funding_decision_ioj_result, funding_decision.interests_of_justice&.result
          ),
          Components::FreeTextAnswer.new(
            :funding_decision_ioj_reason, funding_decision.interests_of_justice&.details
          ),
          Components::FreeTextAnswer.new(
            :funding_decision_ioj_caseworker, funding_decision.interests_of_justice&.assessed_by
          ),
          Components::DateAnswer.new(
            :funding_decision_ioj_date, funding_decision.interests_of_justice&.assessed_on
          ),
          Components::ValueAnswer.new(
            :funding_decision_means_result, funding_decision.means&.result
          ),
          Components::FreeTextAnswer.new(
            :funding_decision_means_caseworker, funding_decision.means&.assessed_by
          ),
          Components::DateAnswer.new(
            :funding_decision_means_date, funding_decision.means&.assessed_on
          ),
          Components::ValueAnswer.new(
            :funding_decision_overall_result, overall_result
          ),
          Components::FreeTextAnswer.new(
            :funding_decision_further_info, funding_decision.comment
          )
        ].select(&:show?)
      end

      def name
        I18n.t('summary.sections.case')
      end

      def status_tag
        nil
      end

      # TODO: source from datastore once decision on simplified statuses resolved
      def overall_result
        return 'granted_failed_means' if granted? && failed_means?
        return 'granted_with_contribution' if granted? && with_contribution?

        record.funding_decision
      end

      def granted?
        record.funding_decision == 'granted'
      end

      def failed_means?
        record.means&.result == 'failed'
      end

      def with_contribution?
        record.means&.result == 'passed_with_contribution'
      end

      def funding_decision
        @funding_decision ||= record
      end
    end
  end
end
