desc 'Submit DraftCreated events for all drafts'
task submit_draft_created_events: [:environment] do
  require 'csv'

  failed_events = []
  CrimeApplication.order(created_at: :asc).find_each do |crime_application|
    begin
      Datastore::Events::DraftCreated.new(
        entity_id: crime_application.id,
        entity_type: crime_application.application_type,
        business_reference: crime_application.reference,
        created_at: crime_application.created_at
      ).call
    rescue StandardError => e
      failed_events << crime_application.id
      puts "Failed #{crime_application.id}: #{e.message}"
      next
    end
  end

  CSV.open('/tmp/failed_draft_created_events.csv', 'w', write_headers: true, headers: ['id']) do |csv|
    failed_events.each { |id| csv << [id] }
  end

  puts 'Done'
end
