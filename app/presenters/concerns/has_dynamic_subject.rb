module HasDynamicSubject
  extend ActiveSupport::Concern

  include ActionView::Helpers::OutputSafetyHelper

  def title
    safe_join([super, title_subject].compact)
  end

  def title_subject
    return unless show_subject?

    ": #{I18n.t("summary.dictionary.subjects.#{subject_type}")}"
  end

  def show_subject?
    return false if crime_application.nil?

    crime_application.applicant.has_partner == 'yes'
  end
end
