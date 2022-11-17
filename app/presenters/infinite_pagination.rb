# FIXME: implement tests if we decide to go with DynamoDB.
# This will not be neccessary if we decide to go with Postgres, as then
# we can use traditional pagination and there are good gems for that.
# :nocov:
class InfinitePagination < BasePresenter
  def initialize(pagination:, params:)
    @unfiltered_params = params

    super(
      pagination
    )
  end

  def to_partial_path
    'shared/infinite_pagination'.freeze
  end

  def show?
    total > limit
  end

  def total_pages
    (total / limit.to_f).ceil
  end

  def current_page
    index = params[:p].to_i
    index += 1 if index.zero?

    [index, total_pages].min
  end

  def next_page
    current_page + 1
  end

  def next_page_params
    params.merge(page_token: next_page_token, p: next_page)
  end

  def start_page_params
    params.except(:page_token, :p)
  end

  private

  def params
    @unfiltered_params.permit(
      :q, :p, :limit, :sort, :page_token
    )
  end
end
# :nocov:
