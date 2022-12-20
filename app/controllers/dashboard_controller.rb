class DashboardController < ApplicationController
  helper_method :in_progress_count, :returned_count, :status_filter
  delegate :returned_count, to: :application_counters

  private

  def in_progress_count
    in_progress_scope.count
  end

  def status_filter
    ApplicationStatus::IN_PROGRESS.to_s
  end

  def in_progress_scope
    CrimeApplication.where(office_code: current_office_code)
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
    @application_counters ||= Datastore::ApplicationCounters.new(
      office_code: current_office_code
    )
  end
end
