class DashboardController < ApplicationController
  helper_method :in_progress_count, :returned_count, :sortable_columns
  delegate :returned_count, to: :application_counters

  private

  # Implement in sub-controllers to narrow down allowed columns
  # :nocov:
  def sortable_columns
    []
  end
  # :nocov:

  def in_progress_count
    in_progress_scope.count
  end

  def in_progress_scope
    CrimeApplication.where(office_code: current_office_code)
                    .joins(:people)
                    .includes(:applicant)
                    .merge(Applicant.with_name)
  end

  def application_counters
    @application_counters ||= Datastore::ApplicationCounters.new(
      office_code: current_office_code
    )
  end
end
