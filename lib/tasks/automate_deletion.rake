desc 'Automated deletions of applications'

task automate_deletion: [:environment] do
  puts 'Start of automated deletion task'

  #debugger

  puts "#{CrimeApplication.to_be_soft_deleted.count} application(s) will be marked for soft deletion"
  CrimeApplication.to_be_soft_deleted.update_all(soft_deleted_at: Time.now)

  puts "#{CrimeApplication.to_be_hard_deleted.count} application(s) will be deleted"
  CrimeApplication.to_be_hard_deleted.each do |application|
    ApplicationPurger.call(application, LogContext.new)
  end

  puts 'End of automated deletion task.'
end
