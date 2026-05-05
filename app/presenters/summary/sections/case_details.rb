module Summary
  module Sections
    class CaseDetails < Sections::BaseSection
      def show?
        kase.present? && super
      end

      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      def answers
        [
          # This is an optional field, depending on case type
          # If it is an empty string (not nil), it will show as `None`
          Components::FreeTextAnswer.new(
            :case_urn, kase.urn,
            show: true,
            change_path: edit_steps_case_urn_path
          ),

          Components::ValueAnswer.new(
            :case_type, kase.case_type,
            change_path: edit_steps_client_case_type_path
          ),

          # START: Appeal to crown court case type questions
          Components::DateAnswer.new(
            :appeal_lodged_date, kase.appeal_lodged_date,
            change_path: edit_steps_client_appeal_details_path
          ),

          Components::ValueAnswer.new(
            :appeal_original_app_submitted, kase.appeal_original_app_submitted,
            change_path: edit_steps_client_appeal_details_path
          ),

          Components::ValueAnswer.new(
            :appeal_financial_circumstances_changed, kase.appeal_financial_circumstances_changed,
            change_path: edit_steps_client_appeal_financial_circumstances_path
          ),

          Components::FreeTextAnswer.new(
            :appeal_with_changes_details, kase.appeal_with_changes_details,
            change_path: edit_steps_client_appeal_financial_circumstances_path
          ),

          Components::FreeTextAnswer.new(
            :appeal_maat_id, kase.appeal_maat_id,
            change_path: edit_steps_client_appeal_reference_number_path
          ),

          Components::FreeTextAnswer.new(
            :appeal_usn, kase.appeal_usn,
            change_path: edit_steps_client_appeal_reference_number_path
          ),
          # END: Appeal to crown court case type questions

          Components::ValueAnswer.new(
            :has_case_concluded, kase.has_case_concluded,
            change_path: case_concluded_change_path
          ),

          Components::DateAnswer.new(
            :date_case_concluded, kase.date_case_concluded,
            show: case_concluded?,
            change_path: case_concluded_change_path
          ),

          Components::ValueAnswer.new(
            :is_preorder_work_claimed, kase.is_preorder_work_claimed,
            change_path: preorder_work_claimed_path
          ),

          Components::DateAnswer.new(
            :preorder_work_date, kase.preorder_work_date,
            show: preorder_work_claimed?,
            change_path: preorder_work_claimed_path
          ),

          Components::FreeTextAnswer.new(
            :preorder_work_details, kase.preorder_work_details,
            show: preorder_work_claimed?,
            change_path: preorder_work_claimed_path
          ),

          Components::ValueAnswer.new(
            :is_client_remanded, kase.is_client_remanded,
            change_path: client_remanded_change_path
          ),

          Components::DateAnswer.new(
            :date_client_remanded, kase.date_client_remanded,
            show: client_remanded?,
            change_path: client_remanded_change_path
          ),
        ].select(&:show?)
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

      def heading
        :case_details_and_offences
      end

      private

      def case_concluded?
        kase.has_case_concluded == 'yes' && kase.date_case_concluded.present?
      end

      def preorder_work_claimed?
        kase.is_preorder_work_claimed == 'yes' &&
          kase.preorder_work_date.present? &&
          kase.preorder_work_details.present?
      end

      def client_remanded?
        kase.is_client_remanded == 'yes' && kase.date_client_remanded.present?
      end

      def case_concluded_change_path
        edit_steps_case_has_case_concluded_path
      end

      def preorder_work_claimed_path
        edit_steps_case_is_preorder_work_claimed_path
      end

      def client_remanded_change_path
        edit_steps_case_is_client_remanded_path
      end
    end
  end
end
