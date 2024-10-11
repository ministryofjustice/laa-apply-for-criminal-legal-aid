module Summary
  module Components
    class BaseAnswer
      include ActionView::Helpers
      include ApplicationHelper
      include StepsHelper

      attr_reader :question, :value, :show, :change_path, :changed

      DEFAULT_OPTIONS = { default: nil, show: nil, change_path: nil, i18n_opts: {}, subject_type: nil,
                          changed: nil }.freeze

      def initialize(question, value, *args)
        options = extract_supported_options!(args)

        @question = question
        @value = value || options[:default]
        @show = options[:show]
        @change_path = options[:change_path]
        @subject_type = options[:subject_type]
        @i18n_opts = options[:i18n_opts]
        @changed = options[:changed]
      end

      def show?
        show.nil? ? value? : show
      end

      def value?
        value.present?
      end

      def change_link?
        change_path.present?
      end

      def changed?
        !!changed
      end

      def question_text
        translate_with_subject(
          "summary.questions.#{question}.question", **i18n_opts
        )
      end

      # :nocov:
      def answer_text
        raise 'must be implemented in subclasses'
      end
      # :nocov:

      def absence_answer
        I18n.t("summary.questions.#{question}.absence_answer")
      end

      def visually_hidden_action_text
        I18n.t("summary.questions.#{question}.question_a11y", default: question_text)
      end

      def i18n_opts
        return @i18n_opts if @i18n_opts.key?(:subject_type)

        @i18n_opts.merge(
          subject_type: subject_type,
          subject: translate("summary.dictionary.subjects.#{subject_type}"),
          ownership: translate("summary.dictionary.ownership.#{subject_type}"),
        )
      end

      private

      def subject_type
        @subject_type ||= SubjectType.new(:applicant)
      end

      def extract_supported_options!(args)
        options = DEFAULT_OPTIONS.merge(args.extract_options!)
        options.assert_valid_keys(DEFAULT_OPTIONS.keys)
        options
      end
    end
  end
end
