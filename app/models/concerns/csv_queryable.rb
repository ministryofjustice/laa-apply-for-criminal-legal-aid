require 'csv'

module CsvQueryable
  extend ActiveSupport::Concern

  CSV::Converters[:boolean] = lambda do |field|
    case field
    when /\Atrue\z/i  then true
    when /\Afalse\z/i then false
    else; field
    end
  end

  attr_reader :row

  def initialize(row:)
    @row = row
  end

  def ==(other)
    other.is_a?(self.class) && other.row == row
  end
  alias === ==
  alias eql? ==

  def hash
    [self.class, row].hash
  end

  class_methods do
    def csv_filepath(filepath)
      self.filepath = filepath
    end

    def csv_attributes(*attrs)
      attrs.each do |name|
        define_method(name) { row[name] }
      end
    end

    def find_by(**query)
      attr, value = query.first
      all.find { |obj| obj.public_send(attr) == value }
    end

    def all
      @all ||= csv.map { |row| new(row:) }
    end

    private

    attr_accessor :filepath

    def csv
      CSV.read(
        @filepath,
        headers: true,
        header_converters: :symbol,
        converters: [:boolean]
      )
    end
  end
end
