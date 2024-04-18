module Summary
  module Sections
    class CapitalLoopBase < Sections::BaseSection
      include TypeOfMeansAssessment

      def show?
        capital && requires_full_capital?
      end

      def answers
        if records.empty?
          [
            Components::ValueAnswer.new(
              question, absence_answer,
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

      def absence_answer
        'none'
      end
    end
  end
end
