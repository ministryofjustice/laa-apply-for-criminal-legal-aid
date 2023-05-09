class Offence
  include CsvQueryable

  csv_filepath Rails.root.join('config/data/offences.csv')

  csv_attributes :code,
                 :name,
                 :offence_class,
                 :offence_type,
                 :ioj_passport

  def self.find_by_name(name)
    find_by(name:)
  end
end
