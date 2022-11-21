# FIXME: implement tests if we decide to go with DynamoDB.
# This will not be neccessary if we decide to go with Postgres, as then
# we can use traditional pagination and there are good gems for that.
# :nocov:
class InfinitePaginationV2 < BasePresenter
  def initialize(pagination:, params:)
    @unfiltered_params = params

    # rubocop:disable Style/OpenStructUse
    super(
      OpenStruct.new(pagination)
    )
    # rubocop:enable Style/OpenStructUse
  end

  def to_partial_path
    'shared/infinite_pagination_v2'.freeze
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

  def aria_current
    current_page == params[:p] ? 'page' : nil
  end

  def next_page
    current_page + 1
  end

  def prev_page
    if previous_page_token.present?
      [current_page - 1, 1].max
    else
      1 # always first page once we lack prev pointer
    end
  end

  def current_page_token
    params[:page_token]
  end

  def previous_page_token
    params[:previous_page_token]
  end

  def next_page_params
    params.merge(page_token: next_page_token, previous_page_token: current_page_token, p: next_page)
  end

  def previous_page_params
    params.except(:previous_page_token).merge(page_token: previous_page_token, p: prev_page)
  end

  def start_page_params
    params.except(:page_token, :previous_page_token, :p)
  end

  private

  def params
    @unfiltered_params.permit(
      :v, :q, :p, :limit, :sort, :page_token, :previous_page_token
    )
  end
end
# :nocov:
