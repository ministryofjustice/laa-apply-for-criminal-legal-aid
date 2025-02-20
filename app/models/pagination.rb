class Pagination
  include ActiveModel::Model
  include ActiveModel::Attributes

  DEFAULT_LIMIT_VALUE = Kaminari.config.default_per_page
  DEFAULT_CURRENT_PAGE = 1

  attribute :current_page, :integer, default: DEFAULT_CURRENT_PAGE
  attribute :limit_value, :integer, default: DEFAULT_LIMIT_VALUE
  attribute :total_pages, :integer
  attribute :total_count, :integer

  def datastore_params
    {
      page: current_page,
      per_page: limit_value
    }
  end

  def limit_value
    return DEFAULT_LIMIT_VALUE unless super

    super
  end

  def current_page
    return DEFAULT_CURRENT_PAGE unless super

    super
  end
end
