module Refinements
  module TranslateWithSubject
    def self.included(base)
      base.class_eval { alias_method :t, :translate_with_subject }
    end

    def translate_with_subject(key, **options)
      conjunction = options.fetch(:conjunction, :or)

      options[:subject] ||= I18n.t("dictionary.subject.#{ownership_type}", conjunction:)

      translate(key, **options)
    end
  end
end
