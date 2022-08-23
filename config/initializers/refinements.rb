require_relative '../../app/lib/refinements/decorate_collection'
require_relative '../../app/lib/refinements/present_collection'

class Array
  include Refinements::DecorateCollection
  include Refinements::PresentCollection
end

class ActiveRecord::Relation
  include Refinements::DecorateCollection
  include Refinements::PresentCollection
end
