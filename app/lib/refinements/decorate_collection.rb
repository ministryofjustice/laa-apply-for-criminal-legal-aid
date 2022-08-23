module Refinements
  module DecorateCollection
    # :nocov:
    def decorate_each(decorator)
      each do |obj|
        yield decorator.new(obj)
      end
    end

    def self.included(base)
      refine base do
        import_methods Refinements::DecorateCollection
      end
    end
    # :nocov:
  end
end
