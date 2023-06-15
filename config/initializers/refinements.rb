Dir[File.expand_path('app/lib/refinements') + '/*.rb'].each { |f| require f }

ActionView::Helpers::TranslationHelper.include Refinements::LocalizeWithTz

Array.include Refinements::DecorateCollection,
              Refinements::PresentCollection

ActiveRecord::Relation.include Refinements::DecorateCollection,
                               Refinements::PresentCollection
