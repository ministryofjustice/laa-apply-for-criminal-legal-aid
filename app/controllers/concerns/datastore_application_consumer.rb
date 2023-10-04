module DatastoreApplicationConsumer
  extend ActiveSupport::Concern

  private

  def current_crime_application
    return if application_id.blank?
    return @current_crime_application if @current_crime_application

    crime_application = Datastore::GetApplication.new(application_id).call

    return unless crime_application.dig('provider_details', 'office_code') == current_office_code

    @current_crime_application = crime_application
  end
end
