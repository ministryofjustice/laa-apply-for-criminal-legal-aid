class BasePresenter < SimpleDelegator
  include ActionView::Helpers::TranslationHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  def self.present(model)
    ApplicationController.helpers.present(model, self)
  end
end
