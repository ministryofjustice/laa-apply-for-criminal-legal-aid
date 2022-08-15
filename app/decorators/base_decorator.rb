class BaseDecorator < SimpleDelegator
  def self.decorate(model)
    ApplicationController.helpers.decorate(model, self)
  end
end
