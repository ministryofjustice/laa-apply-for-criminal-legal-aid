require_relative '../../app/lib/refinements/decorate_collection'

class Array
  include Refinements::DecorateCollection
end

class ActiveRecord::Relation
  include Refinements::DecorateCollection
end
