{
  en: {
    dictionary: {
      subject: lambda { |key, options|
        subject_type = options[:subject_type] || 'applicant'
        I18n.t("dictionary.subjects.#{subject_type.to_s}")
      }
    }
  },
  cy: {
    dictionary: {
      subject: lambda { |key, options|
        subject_type = options[:subject_type] || 'applicant'
        I18n.t("dictionary.subjects.#{subject_type.to_s}")
      }
    }
  }
}
