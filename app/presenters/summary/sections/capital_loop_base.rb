module Summary
  module Sections
    class CapitalLoopBase < Sections::BaseSection
      def show?
        capital && requires_full_capital
      end

      def answers
        if records.empty?
          [
            Components::ValueAnswer.new(
              question, 'no',
              change_path: edit_path
            )
          ]
        else
          list_component
        end
      end

      def list?
        return false if records.empty?

        true
      end

      private

      # :nocov:
      def records
        raise 'must be implemented in subclasses'
      end
      # :nocov:

      def capital
        @capital ||= crime_application.capital
      end

      def requires_full_capital
        [
          CaseType::EITHER_WAY.to_s,
          CaseType::INDICTABLE.to_s,
          CaseType::ALREADY_IN_CROWN_COURT.to_s
        ].include?(crime_application.case.case_type)
      end
    end
  end
end
