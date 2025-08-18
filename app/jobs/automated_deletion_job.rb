class AutomatedDeletionJob < ApplicationJob
  queue_as :automated_deletions

  def perform
    CrimeApplication.to_be_soft_deleted.update_all(soft_deleted_at: Time.now)

    CrimeApplication.to_be_hard_deleted.each do |application|
      ApplicationPurger.call(application, log_context)
    end
  end

  private

  def log_context
    LogContext.new
  end
end
