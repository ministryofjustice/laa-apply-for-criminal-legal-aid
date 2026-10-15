class Offence
  include CsvQueryable

  csv_filepath Rails.root.join('config/data/offences.csv')

  csv_attributes :code,
                 :name,
                 :offence_class,
                 :offence_type,
                 :slipstreamable

  # Saved charges and returned applications contain the original name, not the
  # offence code. Keep each old name associated with its original code and band.
  LEGACY_NAMES = {
    'Handle stolen goods (£30,000 or less)' =>
      'Handling stolen goods, buying - Theft Act 1968 (£30,000 or less)',
    'Handle stolen goods (Over £30,000 up to £100,000)' =>
      'Handling stolen goods, buying - Theft Act 1968 (Over £30,000 up to £100,000)',
    'Handle stolen goods (Over £100,000)' =>
      'Handling stolen goods, buying - Theft Act 1968 (Over £100,000)',
    'Handling stolen goods - Theft Act 1968 (£30,000 or less)' =>
      'Handle stolen goods, selling (£30,000 or less)',
    'Handling stolen goods - Theft Act 1968 (Over £30,000 up to £100,000)' =>
      'Handle stolen goods, selling (Over £30,000 up to £100,000)',
    'Handling stolen goods - Theft Act 1968 (Over £100,000)' =>
      'Handle stolen goods, selling (Over £100,000)',
  }.freeze

  def self.find_by_name(name)
    find_by(name: LEGACY_NAMES.fetch(name, name))
  end
end
