class InProgressSorting
  include ActiveModel::Model
  include ActiveModel::Attributes

  SORT_COLUMNS = {
    applicant_name: [:last_name, :first_name],
    application_type: [:application_type],
    reference: [:reference],
    created_at: [:created_at],
  }.freeze

  DEFAULT_SORT_BY = :created_at
  DEFAULT_DIRECTION = :desc

  attribute :sort_by, :string, default: DEFAULT_SORT_BY
  attribute :sort_direction, :string, default: DEFAULT_DIRECTION

  def apply_to_scope(scope)
    scope.order(**order_params)
  end

  def order_params
    column_names.index_with { sort_direction.to_sym }
  end

  def reverse_direction
    return 'asc' if sort_direction == 'desc'

    'desc'
  end

  private

  def column_names
    SORT_COLUMNS.fetch(sort_by.to_sym)
  end

  def direction
    SORT_DIRECTIONS.fetch(sort_direction.to_sym)
  end
end
