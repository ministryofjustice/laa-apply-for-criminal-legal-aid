module DatastoreApplicationConsumer
  extend ActiveSupport::Concern

  private

  def current_crime_application
    return if application_id.blank?

    @current_crime_application ||= Datastore::GetApplication.new(application_id).call
  end
end
