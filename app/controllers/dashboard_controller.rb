class DashboardController < ApplicationController
  helper_method :in_progress_count, :submitted_count, :returned_count
  delegate :submitted_count, :returned_count, to: :application_counters

  def in_progress_count
    in_progress_scope.count
  end

  private

  # TODO: filter by provider's office code
  def in_progress_scope
    CrimeApplication.in_progress
                    .joins(:people)
                    .includes(:applicant)
                    .merge(Applicant.with_name)
  end

  def present_crime_application
    @crime_application = helpers.present(
      current_crime_application, CrimeApplicationPresenter
    )
  end

  def application_counters
    @application_counters ||= Datastore::ApplicationCounters.new
  end
end
