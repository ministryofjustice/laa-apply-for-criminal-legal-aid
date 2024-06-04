{
  en: {
    dictionary: {
      subject: lambda { |key, options|
        ownership_type = options[:ownership_type] || :applicant
        I18n.t("dictionary.subjects.#{ownership_type}", conjunction: 'or')
      }
    }
  }
}
