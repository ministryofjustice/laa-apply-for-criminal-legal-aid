class BasePresenter < SimpleDelegator
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  delegate :t, :t!, :l, to: I18n

  def self.present(model)
    ApplicationController.helpers.present(model, self)
  end
end
