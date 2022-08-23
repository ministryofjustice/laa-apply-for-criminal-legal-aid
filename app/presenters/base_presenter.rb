class BasePresenter < SimpleDelegator
  def self.present(model)
    ApplicationController.helpers.present(model, self)
  end
end
