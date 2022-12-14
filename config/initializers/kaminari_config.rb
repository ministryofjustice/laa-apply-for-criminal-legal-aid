# frozen_string_literal: true

Kaminari.configure do |config|
  config.default_per_page = 1
  config.outer_window = 1
  config.window = 10
end
