module Summary
  module Sections
    class ClientOtherCharge < Sections::BaseSection
      def show?
        kase.present? && kase.client_other_charge_in_progress.present? && super
      end

      def answers # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
        [
          Components::ValueAnswer.new(
            :client_other_charge_in_progress, kase.client_other_charge_in_progress,
            change_path: edit_steps_case_other_charge_in_progress_path(subject: 'client')
          ),
          Components::FreeTextAnswer.new(
            :client_other_charge_charge, kase.client_other_charge&.charge,
            change_path: edit_steps_case_other_charge_path(subject: 'client'),
          ),
          Components::FreeTextAnswer.new(
            :client_other_charge_hearing_court_name, kase.client_other_charge&.hearing_court_name,
            change_path: edit_steps_case_other_charge_path(subject: 'client'),
          ),
          Components::DateAnswer.new(
            :client_other_charge_next_hearing_date, kase.client_other_charge&.next_hearing_date,
            change_path: edit_steps_case_other_charge_path(subject: 'client'),
          ),
        ].select(&:show?)
      end

      def title
        if kase.partner_other_charge_in_progress.present?
          I18n.t(
            :client_other_charge_explicit,
            scope: 'summary.sections',
            subject: I18n.t("summary.dictionary.subjects.#{subject_type}"),
            ownership: I18n.t("summary.dictionary.ownership.#{subject_type}"),
            count: subject_type.to_s == SubjectType::APPLICANT_AND_PARTNER.to_s ? 2 : 1
          )
        else
          super
        end
      end
    end
  end
end
