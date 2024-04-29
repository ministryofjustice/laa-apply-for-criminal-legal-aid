module Summary
  module Sections
    # rubocop:disable Naming/PredicateName, Metrics/MethodLength, Metrics/AbcSize
    class PremiumBonds < Sections::BaseSection
      def show?
        shown_premium_bonds? && super
      end

      def answers
        [
          Components::ValueAnswer.new(
            :has_premium_bonds,
            crime_application.capital.has_premium_bonds,
            change_path:
          ),
          Components::FreeTextAnswer.new(
            :premium_bonds_holder_number,
            crime_application.capital.premium_bonds_holder_number,
            change_path: change_path,
            show: have_premium_bonds?
          ),
          Components::MoneyAnswer.new(
            :premium_bonds_total_value,
            crime_application.capital.premium_bonds_total_value,
            change_path: change_path,
            show: have_premium_bonds?
          )
        ].select(&:show?)
      end

      private

      def shown_premium_bonds?
        capital.present? && capital.has_premium_bonds.present?
      end

      def have_premium_bonds?
        YesNoAnswer.new(capital.has_premium_bonds).yes?
      end

      def change_path
        edit_steps_capital_premium_bonds_path(crime_application)
      end
    end
    # rubocop:enable Naming/PredicateName, Metrics/MethodLength, Metrics/AbcSize
  end
end
