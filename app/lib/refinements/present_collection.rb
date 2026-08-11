module Refinements
  module PresentCollection
    # simplecov:disable
    def present_each(presenter)
      each do |obj|
        yield presenter.new(obj)
      end
    end

    def presented_map(presenter)
      map do |obj|
        presenter.new(obj)
      end
    end
    # simplecov:enable
  end
end
