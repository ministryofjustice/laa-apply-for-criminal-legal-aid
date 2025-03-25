class ReturnedApplicationsController < CompletedApplicationsController
  include DatastoreApi::SortedResults

  before_action :check_crime_application_presence, :present_crime_application,
                only: %i[confirm_destroy draft_application_found archive]

  def index
    set_search(filter: { status: %w[returned] })
  end

  def confirm_destroy
    redirect_to action: 'draft_application_found' if @crime_application.draft.present?
  end

  def draft_application_found
    @draft = @crime_application.draft
  end

  def archive
    Datastore::ArchiveApplication.new(@crime_application.id).call
    redirect_to returned_applications_path,
                flash: { success: t('.success_flash', applicant_name: @crime_application.applicant_name) }
  end
end
