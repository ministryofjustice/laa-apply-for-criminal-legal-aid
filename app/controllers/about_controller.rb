class AboutController < ApplicationController
  skip_before_action :authenticate_user!

  def privacy; end
  def contact; end
  def feedback; end
  def accessibility; end
end
