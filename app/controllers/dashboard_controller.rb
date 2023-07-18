class DashboardController < ApplicationController
  helper_method :in_progress_count, :returned_count, :sortable_columns
  delegate :returned_count, to: :application_counters

  # Avoid the browser caching any of the dashboard pages so the
  # back button after signing out can't load any sensitive details
  before_action :no_store

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
    CrimeApplication.with_applicant.where(office_code: current_office_code)
  end

  def application_counters
    @application_counters ||= Datastore::ApplicationCounters.new(
      office_code: current_office_code
    )
  end
end
