class ApplicationSearchSorting
  include ActiveModel::Model
  include ActiveModel::Attributes

  SORTABLE_COLUMNS = %w[
    applicant_name
    application_type
    submitted_at
    reference
  ].freeze

  DEFAULT_SORT_BY = 'submitted_at'.freeze
  DEFAULT_SORT_DIRECTION = 'ascending'.freeze

  attribute :sort_direction, :string, default: DEFAULT_SORT_DIRECTION
  attribute :sort_by, :string, default: DEFAULT_SORT_BY

  def reverse_direction
    return 'ascending' if sort_direction == 'descending'

    'descending'
  end
end
