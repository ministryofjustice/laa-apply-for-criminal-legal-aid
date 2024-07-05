module Steps
  module SubjectResource
    extend ActiveSupport::Concern

    included do
      before_action :set_subject
    end

    private

    def set_subject
      case params[:subject]
      when /client/
        @subject = current_crime_application.applicant
      when /partner/
        raise Errors::SubjectNotFound unless MeansStatus.include_partner?(current_crime_application)

        @subject = current_crime_application.partner
      else
        raise Errors::SubjectNotFound
      end
    end
  end
end
