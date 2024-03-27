module Summary
  module Components
    class BaseAnswer
      include ActionView::Helpers

      attr_reader :question, :value, :show, :change_path, :i18n_opts

      DEFAULT_OPTIONS = { default: nil, show: nil, change_path: nil, i18n_opts: {} }.freeze

      def initialize(question, value, *args)
        options = extract_supported_options!(args)

        @question = question
        @value = value || options[:default]
        @show = options[:show]
        @change_path = options[:change_path]
        @i18n_opts = options[:i18n_opts]
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

      def question_text
        I18n.t("summary.questions.#{question}.question", **i18n_opts)
      end

      def answer_text
        value.to_s
      end

      def absence_answer
        I18n.t("summary.questions.#{question}.absence_answer")
      end

      def visually_hidden_action_text
        I18n.t("summary.questions.#{question}.question_a11y", default: question_text)
      end

      private

      def extract_supported_options!(args)
        options = DEFAULT_OPTIONS.merge(args.extract_options!)
        options.assert_valid_keys(DEFAULT_OPTIONS.keys)
        options
      end
    end
  end
end
