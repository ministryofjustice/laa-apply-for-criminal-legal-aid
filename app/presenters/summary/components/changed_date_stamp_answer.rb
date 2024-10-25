module Summary
  module Components
    class ChangedDateStampAnswer < BaseAnswer
      include Refinements::LocalizeWithTz

      def answer_text
        safe_join [output, changed_message_tag]
      end

      def output
        if value.respond_to?(:strftime)
          simple_format(l(value.in_time_zone, **i18n_opts))
        else
          simple_format(value.presence || absence_answer)
        end
      end

      def changed_message_tag
        return nil unless changed?

        tag.strong(
          'Changed after date stamp',
          class: 'date-stamp-context__tag govuk-tag govuk-tag--red'
        )
      end
    end
  end
end
