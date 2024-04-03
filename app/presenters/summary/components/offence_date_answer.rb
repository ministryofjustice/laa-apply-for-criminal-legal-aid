module Summary
  module Components
    class OffenceDateAnswer < BaseAnswer
      def answer_text
        safe_join offence_dates
      end

      private

      def offence_dates
        value.offence_dates.map do |date_from, date_to|
          tag.p(
            date_to ? [l(date_from), l(date_to)].join(' – ') : l(date_from),
            class: ['govuk-body', 'govuk-!-margin-bottom-0']
          )
        end
      end
    end
  end
end
