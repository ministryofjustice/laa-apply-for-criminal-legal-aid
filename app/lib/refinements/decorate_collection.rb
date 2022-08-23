module Refinements
  module DecorateCollection
    # :nocov:
    def decorate_each(decorator)
      each do |obj|
        yield decorator.new(obj)
      end
    end
    # :nocov:
  end
end
