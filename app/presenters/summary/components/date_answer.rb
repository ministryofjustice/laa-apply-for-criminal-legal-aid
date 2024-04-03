module Summary
  module Components
    class DateAnswer < BaseAnswer
      include Refinements::LocalizeWithTz

      def answer_text
        l(value.in_time_zone, **i18n_opts) if value
      end
    end
  end
end
