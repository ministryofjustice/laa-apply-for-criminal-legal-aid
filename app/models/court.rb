class Court
  include CsvQueryable

  csv_filepath Rails.root.join('config/data/courts.csv')

  csv_attributes :code, :name

  def self.find_by_name(name)
    find_by(name:)
  end
end
