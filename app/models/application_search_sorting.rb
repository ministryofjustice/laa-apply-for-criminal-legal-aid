class ApplicationSearchSorting
  include ActiveModel::Model
  include ActiveModel::Attributes

  SORTABLE_COLUMNS = %w[
    applicant_name
    application_type
    submitted_at
    reference
    application_status
  ].freeze

  DEFAULT_SORT_BY = 'submitted_at'.freeze
  DEFAULT_SORT_DIRECTION = 'descending'.freeze

  attribute :sort_direction, :string, default: DEFAULT_SORT_DIRECTION
  attribute :sort_by, :string, default: DEFAULT_SORT_BY

  alias params attributes

  def reverse_direction
    return 'ascending' if sort_direction == 'descending'

    'descending'
  end

  def sortable_columns
    SORTABLE_COLUMNS
  end
end
