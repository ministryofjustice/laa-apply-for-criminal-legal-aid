module HasDynamicSubject
  extend ActiveSupport::Concern

  def title
    [super, title_subject].compact.join
  end

  def title_subject
    return unless show_subject?

    ": #{subject_type.to_param}"
  end

  def show_subject?
    return false if crime_application.nil?

    crime_application.applicant.has_partner == 'yes'
  end
end
