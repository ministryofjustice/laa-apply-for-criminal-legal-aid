require 'laa_crime_schemas'

class AddScanResultToDocuments < ActiveRecord::Migration[7.0]
  def up
    supported_statuses = %w[awaiting pass flagged incomplete other]
    statuses = (::LaaCrimeSchemas::Types::VirusScanStatus.values & supported_statuses)
               .map { |s| "'#{s}'" }
               .join(', ')

    execute <<-SQL
      CREATE TYPE virus_scan_status AS ENUM (#{statuses});
    SQL

    add_column :documents, :scan_provider, :string, default: nil
    add_column :documents, :scan_status, :virus_scan_status,
               default: ::LaaCrimeSchemas::Types::VirusScanStatus['awaiting']
    add_column :documents, :scan_output, :string, default: nil
    add_column :documents, :scan_at, :datetime, default: nil
  end

  def down
    remove_column :documents, :scan_provider
    remove_column :documents, :scan_status
    remove_column :documents, :scan_output
    remove_column :documents, :scan_at

    execute <<-SQL
      DROP TYPE virus_scan_status;
    SQL
  end
end
