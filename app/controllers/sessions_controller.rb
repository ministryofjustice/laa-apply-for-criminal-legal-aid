class SessionsController < ApplicationController
  def destroy
    reset_session
    redirect_to root_path
  end

  # NOTE: the following might be reused later on, so leaving it here
  #
  # private
  #
  # :nocov:
  # def crime_application
  #   current_crime_application || initialize_crime_application(
  #     client_has_partner: YesNoAnswer::NO
  #   )
  # end
  #
  # def find_or_create_applicant
  #   Applicant.find_or_initialize_by(crime_application_id: crime_application.id).tap do |record|
  #     unless record.persisted?
  #       record.update(
  #         first_name: 'John',
  #         last_name: 'Test',
  #         date_of_birth: 25.years.ago
  #       )
  #     end
  #   end
  # end
  # :nocov:
end
