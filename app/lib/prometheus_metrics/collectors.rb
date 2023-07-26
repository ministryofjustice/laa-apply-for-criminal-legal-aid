module PrometheusMetrics
  module Collectors
    require_relative 'collectors/base_collector'
    Dir[File.expand_path('collectors/*.rb', __dir__)].each { |f| require f }
  end
end
