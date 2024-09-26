module Summary
  module Sections
    class PartnerOtherCharge < Sections::BaseSection
      def show?
        kase.present? && kase.partner_other_charge_in_progress.present? && super
      end

      def answers # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
        [
          Components::ValueAnswer.new(
            :partner_other_charge_in_progress, kase.partner_other_charge_in_progress,
            change_path: edit_steps_case_other_charge_in_progress_path(subject: 'partner')
          ),
          Components::FreeTextAnswer.new(
            :partner_other_charge_charge, kase.partner_other_charge&.charge,
            change_path: edit_steps_case_other_charge_path(subject: 'partner'),
          ),
          Components::FreeTextAnswer.new(
            :partner_other_charge_hearing_court_name, kase.partner_other_charge&.hearing_court_name,
            change_path: edit_steps_case_other_charge_path(subject: 'partner'),
          ),
          Components::DateAnswer.new(
            :partner_other_charge_next_hearing_date, kase.partner_other_charge&.next_hearing_date,
            change_path: edit_steps_case_other_charge_path(subject: 'partner'),
          ),
        ].select(&:show?)
      end
    end
  end
end
