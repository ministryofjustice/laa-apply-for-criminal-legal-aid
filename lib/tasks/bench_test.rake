require 'csv'
require 'benchmark'

namespace :bench_test do
  desc "Bench test PDA results for provided office codes"
  task pda: :environment do
    input_file = Rails.root.join('tmp', 'bench_test', 'office_codes.csv')
    output_file = Rails.root.join('tmp', 'bench_test', 'office_results.csv')

    unless File.exist?(input_file)
      puts "Input file not found: #{input_file}"
      exit
    end

    results = []
    total_time = Benchmark.realtime do
      CSV.foreach(input_file, headers: true) do |row|
        office_code = row['office_code']
        start_time = Time.now

        result = get_result(office_code)

        duration = Time.now - start_time

        results << (result + [duration.round(4)])
      end
    end

    average_time = results.map { |r| r[3] }.sum / results.size

    CSV.open(output_file, 'w') do |csv|
      csv << ['office_code', 'active','contingent_liability', 'duration_seconds']
      results.each { |r| csv << r }
    end

    puts "Processed #{results.size} office codes."
    puts "Total time: #{total_time.round(2)} seconds"
    puts "Average request time: #{average_time.round(4)} seconds"
  end

  def get_result(office_code)
    office = Providers::GetActiveOffice.call(office_code)

    [office_code, office.active?, office.contingent_liability?]
  rescue 
    [office_code, nil, nil] 
  end
end
