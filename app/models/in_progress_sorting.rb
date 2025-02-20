class InProgressSorting
  include ActiveModel::Model
  include ActiveModel::Attributes

  SORT_COLUMNS = {
    'applicant_name' => [:last_name, :first_name],
    'application_type' => [:application_type],
    'reference' => [:reference],
    'created_at' => [:created_at]
  }.freeze

  SORT_DIRECTIONS = {
    'descending' => :desc,
    'ascending' => :asc
  }.freeze

  DEFAULT_SORT_BY = 'created_at'.freeze
  DEFAULT_DIRECTION = 'descending'.freeze

  attribute :sort_by, :string, default: DEFAULT_SORT_BY
  attribute :sort_direction, :string, default: DEFAULT_DIRECTION

  alias params attributes

  def order_scope
    column_names.index_with { SORT_DIRECTIONS.fetch(sort_direction) }
  end

  def reverse_direction
    return 'ascending' if sort_direction == 'descending'

    'descending'
  end

  def sortable_columns
    SORT_COLUMNS.keys
  end

  def sort_by
    return super if sortable_columns.include?(super)

    DEFAULT_SORT_BY
  end

  def sort_direction
    return super if SORT_DIRECTIONS.key?(super)

    DEFAULT_DIRECTION
  end

  private

  def column_names
    SORT_COLUMNS.fetch(sort_by)
  end
end
