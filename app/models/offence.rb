class Offence
  include CsvQueryable

  csv_filepath Rails.root.join('config/data/offences.csv')

  csv_attributes :code,
                 :name,
                 :offence_class,
                 :offence_type
end
