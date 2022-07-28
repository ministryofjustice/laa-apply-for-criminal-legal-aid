Dir[File.expand_path('app/attributes/type') + '/*.rb'].each { |f| require f }

ActiveModel::Type.register(:string, Type::StrippedString)
ActiveModel::Type.register(:yes_no, Type::YesNoType)
