Dir[File.expand_path('app/lib/refinements') + '/*.rb'].each { |f| require f }

ActionView::Helpers::TranslationHelper.include Refinements::LocalizeWithTz

# Introduce nice utility methods
Array.include Refinements::PresentCollection
ActiveRecord::Relation.include Refinements::PresentCollection
