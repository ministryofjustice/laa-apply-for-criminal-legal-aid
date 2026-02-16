# frozen_string_literal: true

namespace :coverage do
  desc 'Merge SimpleCov coverage reports from parallel CI runs'
  task :merge_reports do
    require 'simplecov'
    require 'simplecov_json_formatter'

    SimpleCov.collate Dir['coverage/.resultset-*.json'] do
      add_filter 'app/mailers/application_mailer.rb'
      add_filter 'app/jobs/application_job.rb'
      add_filter 'config/initializers'
      add_filter 'config/routes.rb'
      add_filter 'lib/rubocop/'
      add_filter 'spec/'

      track_files '{app,lib}/**/*.rb'

      minimum_coverage 100

      formatter SimpleCov::Formatter::MultiFormatter.new([
        SimpleCov::Formatter::SimpleFormatter,
        SimpleCov::Formatter::HTMLFormatter,
        SimpleCov::Formatter::JSONFormatter
      ])
    end

    # Report files with less than 100% coverage
    coverage_data = JSON.parse(File.read('coverage/coverage.json'))
    files_with_gaps = []

    coverage_data['coverage'].each do |file, data|
      lines = data['lines']
      next unless lines

      relevant = lines.compact.reject { |hits| hits.is_a?(String) }
      covered = relevant.count { |hits| hits > 0 }
      total = relevant.size

      if covered < total
        files_with_gaps << {
          file: file.sub("#{Dir.pwd}/", ''),
          covered: covered,
          total: total,
          percent: (covered.to_f / total * 100).round(2)
        }
      end
    end

    if files_with_gaps.any?
      puts "\n#{'=' * 80}"
      puts "Files with less than 100% coverage (#{files_with_gaps.size} files):"
      puts '=' * 80
      files_with_gaps.sort_by { |f| f[:percent] }.each do |f|
        puts "  #{f[:percent]}% - #{f[:file]} (#{f[:covered]}/#{f[:total]} lines)"
      end
      puts '=' * 80
    else
      puts "\n✓ All files have 100% coverage!"
    end
  end
end
