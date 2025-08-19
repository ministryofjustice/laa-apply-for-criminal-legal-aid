class AutomatedDeletion
  def self.call # rubocop:disable Metrics/AbcSize
    Rails.logger.info('Start of automated deletion')

    Rails.logger.info("#{CrimeApplication.to_be_soft_deleted.count} application(s) will be marked for soft deletion")
    CrimeApplication.to_be_soft_deleted.update_all(soft_deleted_at: Time.zone.now) # rubocop:disable Rails/SkipsModelValidations

    Rails.logger.info("#{CrimeApplication.to_be_hard_deleted.count} application(s) will be deleted")
    CrimeApplication.to_be_hard_deleted.each do |application|
      ApplicationPurger.call(application, LogContext.new)
    end

    Rails.logger.info('End of automated deletion task')
  end
end
