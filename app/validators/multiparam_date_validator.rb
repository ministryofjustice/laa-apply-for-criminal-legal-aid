class MultiparamDateValidator < ActiveModel::EachValidator
  DATE_STRUCT = Struct.new('DateStruct', :day, :month, :year, keyword_init: true)

  DEFAULT_OPTIONS = {
    earliest_year: 1900,
    latest_year: 2050,
    allow_past: true,
    allow_future: false,
  }.freeze

  attr_reader :record, :attribute, :config

  def initialize(options)
    super
    @config = DEFAULT_OPTIONS.merge(options)
  end

  def validate_each(record, attribute, value)
    # this will trigger a `:blank` error when `presence: true`
    return if value.blank?

    @record = record
    @attribute = attribute

    # If the value is a hash, we use a simple struct to keep a
    # consistent interface, similar to a real date object.
    # Remember, the hash will have the format: {3=>31, 2=>12, 1=>2000}
    # where `3` is the day, `2` is the month and `1` is the year.
    date = if value.is_a?(Hash)
             DATE_STRUCT.new(day: value[3], month: value[2], year: value[1])
           else
             value
           end

    validate_date(date)
  end

  private

  def validate_date(date)
    add_error(:invalid_day)   unless date.day.to_i.between?(1, 31)
    add_error(:invalid_month) unless date.month.to_i.between?(1, 12)
    add_error(:invalid_year)  unless date.year.to_s.length.eql?(4)

    if date.is_a?(Date)
      validate_config_constraints(date)
    else
      # If, after all, we still don't have a valid date object, it means
      # there are additional errors, like June 31st, or day 29 in non-leap year.
      # We just add a generic error as it would be an overkill to set granular
      # errors for all the possible combinations.
      add_error(:invalid)
    end
  end

  # Some basic constrains, for example some dates like DoB can't be in
  # the future, or a date is very far in the past (potential user typo).
  # This kind of validations can be configured passing an options hash
  # when declaring the validation in the attribute.
  # rubocop:disable Metrics/AbcSize
  def validate_config_constraints(date)
    add_error(:past_not_allowed) unless config[:allow_past] || Time.zone.today <= date
    add_error(:future_not_allowed) unless config[:allow_future] || Time.zone.today >= date

    add_error(:year_too_late) if date.year > config[:latest_year]
    add_error(:year_too_early) if date.year < config[:earliest_year]
  end
  # rubocop:enable Metrics/AbcSize

  def add_error(error)
    record.errors.add(attribute, error)
  end
end
