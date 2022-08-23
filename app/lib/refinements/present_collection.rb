module Refinements
  module PresentCollection
    # :nocov:
    def present_each(presenter)
      each do |obj|
        yield presenter.new(obj)
      end
    end
    # :nocov:
  end
end
