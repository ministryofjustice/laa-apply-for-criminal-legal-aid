class SessionsController < ApplicationController
  def destroy
    reset_session
    redirect_to root_path
  end

  # :nocov:
  def bypass_to_client_details
    raise 'For development use only' unless FeatureFlags.developer_tools.enabled?

    find_or_create_applicant

    crime_application.update(
      navigation_stack: %w[/steps/client/has_partner /steps/client/details]
    )

    redirect_to edit_steps_client_details_path
  end
  # :nocov:

  private

  # :nocov:
  def crime_application
    current_crime_application || initialize_crime_application(
      client_has_partner: YesNoAnswer::NO
    )
  end

  def find_or_create_applicant
    Applicant.find_or_initialize_by(crime_application_id: crime_application.id).tap do |record|
      unless record.persisted?
        record.update(
          first_name: 'John',
          last_name: 'Test',
          date_of_birth: 25.years.ago
        )
      end
    end
  end
  # :nocov:
end
