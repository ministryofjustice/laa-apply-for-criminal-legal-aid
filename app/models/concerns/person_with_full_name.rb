module PersonWithFullName
  extend ActiveSupport::Concern

  NAME_ATTRIBUTES = %i[
    first_name
    last_name
  ].freeze

  def full_name
    values_at(
      NAME_ATTRIBUTES
    ).compact_blank.join(' ')
  end
end
