module Summary
  module Components
    class DateAnswer < BaseAnswer
      def answer_text
        I18n.l(value, **i18n_opts)
      end
    end
  end
end
