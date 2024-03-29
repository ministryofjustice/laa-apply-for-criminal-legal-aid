module Summary
  module Sections
    # rubocop:disable Naming/PredicateName, Metrics/MethodLength, Metrics/AbcSize
    class PremiumBonds < Sections::BaseSection
      def show?
        capital.present? && super
      end

      def answers
        [
          Components::ValueAnswer.new(
            :has_premium_bonds,
            crime_application.capital.has_premium_bonds,
            change_path: change_path,
            show: true
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

      def have_premium_bonds?
        YesNoAnswer.new(capital.has_premium_bonds).yes?
      end

      def change_path
        edit_steps_capital_premium_bonds_path(crime_application)
      end

      def capital
        @capital ||= crime_application.capital
      end
    end
    # rubocop:enable Naming/PredicateName, Metrics/MethodLength, Metrics/AbcSize
  end
end
