module Summary
  module Sections
    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    class PartnerPremiumBonds < Sections::BaseSection
      include HasDynamicSubject

      def show?
        show_partner_premium_bonds? && super
      end

      def answers
        [
          Components::ValueAnswer.new(
            :partner_has_premium_bonds,
            crime_application.capital.partner_has_premium_bonds,
            change_path: edit_steps_capital_partner_premium_bonds_path(crime_application)
          ),
          Components::FreeTextAnswer.new(
            :partner_premium_bonds_holder_number,
            crime_application.capital.partner_premium_bonds_holder_number,
            change_path: edit_steps_capital_partner_premium_bonds_path(crime_application),
            show: partner_have_premium_bonds?
          ),
          Components::MoneyAnswer.new(
            :partner_premium_bonds_total_value,
            crime_application.capital.partner_premium_bonds_total_value,
            change_path: edit_steps_capital_partner_premium_bonds_path(crime_application),
            show: partner_have_premium_bonds?
          )
        ].select(&:show?)
      end

      private

      def show_partner_premium_bonds?
        capital.present? &&
          MeansStatus.include_partner?(crime_application) &&
          capital.partner_has_premium_bonds.present?
      end

      def partner_have_premium_bonds?
        YesNoAnswer.new(capital.partner_has_premium_bonds).yes?
      end

      def subject_type
        SubjectType.new(:partner)
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
  end
end
