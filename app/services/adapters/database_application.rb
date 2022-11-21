module Adapters
  class DatabaseApplication < BaseApplication
    delegate :case_type, to: :case, allow_nil: true
  end
end
