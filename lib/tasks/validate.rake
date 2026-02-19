require 'csv'
require 'benchmark'

namespace :validate do
  desc "Validate schedule data returned by PDA against Contract CL report"
  task pda_schedules: :environment do
    input_file = Rails.root.join('tmp', 'validate', 'cl_office_codes.csv')
    output_file = Rails.root.join('tmp', 'validate', 'cl_results.csv')

    unless File.exist?(input_file)
      puts "Input file not found: #{input_file}"
      exit
    end

    results = []
    total_time = Benchmark.realtime do
      CSV.foreach(input_file, headers: true) do |row|
        office_code = row['office_code']
        start_time = Time.now

        get_schedules(office_code).each do |row|
          results << row
        end
      end
    end

    CSV.open(output_file, 'w') do |csv|
      csv << ['Firm Name','Account Number','Contract Type','Contract Sub Type','Schedule Type', 'Area of Law']
      results.each { |r| csv << r }
    end

    puts "Processed #{results.size} office codes."
    puts "Total time: #{total_time.round(2)} seconds"
  end

  def get_schedules(office_code)
    response = ProviderDataApi::GetOfficeSchedules.call(office_code)

    response.schedules.map do |schedule|
      [response.firm.firmName, office_code, schedule.contractDescription, schedule.contractType, schedule.scheduleType, schedule.areaOfLaw]
    end
  rescue ProviderDataApi::RecordNotFound
    [[nil, office_code, nil, nil, nil, nil]]
  end
end
