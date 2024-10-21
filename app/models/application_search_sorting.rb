class ApplicationSearchSorting < ApplicationStruct
  SORTABLE_COLUMNS = %w[
    applicant_name
    application_type
    submitted_at
    reference
  ].freeze

  SortDirection = Types::String.enum('descending', 'ascending')
  DEFAULT_SORT_BY = 'submitted_at'.freeze
  DEFAULT_SORT_DIRECTION = SortDirection['ascending'].freeze

  attribute? :sort_direction, Types::String.default(DEFAULT_SORT_DIRECTION).enum(*SortDirection.values)
  attribute? :sort_by, Types::String.default(DEFAULT_SORT_BY).enum(*SORTABLE_COLUMNS)

  def sortable_columns
    SORTABLE_COLUMNS
  end

  def reverse_direction
    return 'ascending' if sort_direction == 'descending'

    'descending'
  end
end
