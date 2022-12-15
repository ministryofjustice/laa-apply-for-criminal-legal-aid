class DashboardController < ApplicationController
  helper_method :in_progress_count, :returned_count, :status_filter
  delegate :returned_count, to: :application_counters

  def in_progress_count
    in_progress_scope.count
  end

  def status_filter
    allowed_statuses = [
      ApplicationStatus::SUBMITTED, ApplicationStatus::RETURNED
    ].map(&:to_s)

    allowed_statuses.include?(params[:q]) ? params[:q] : allowed_statuses.first
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
