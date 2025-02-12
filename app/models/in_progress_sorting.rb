class InProgressSorting
  include ActiveModel::Model
  include ActiveModel::Attributes

  SORTABLE_COLUMNS = %w[
    application_type
    created_at
    reference
  ].freeze

  # FIXME: scope these values by sort_by !!!!!!!
  #
  DEFAULT_SORT_BY = 'submitted_at'.freeze
  DEFAULT_SORT_DIRECTION = 'asc'.freeze

  attribute :sort_direction, :string, default: DEFAULT_SORT_DIRECTION
  attribute :sort_by, :string, default: DEFAULT_SORT_BY

  alias params attributes

  def reverse_direction
    return 'asc' if sort_direction == 'desc'

    'desc'
  end

  def active_record
    Hash[sort_by, sort_direction]
  end
end
