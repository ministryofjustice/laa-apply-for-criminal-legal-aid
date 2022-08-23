module Refinements
  module PresentCollection
    # :nocov:
    def present_each(presenter)
      each do |obj|
        yield presenter.new(obj)
      end
    end

    def self.included(base)
      refine base do
        import_methods Refinements::PresentCollection
      end
    end
    # :nocov:
  end
end
