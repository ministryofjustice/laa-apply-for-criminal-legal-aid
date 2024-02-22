Dir[File.expand_path('app/attributes/type') + '/*.rb'].each { |f| require f }

ActiveModel::Type.register(:string, Type::StrippedString)
ActiveModel::Type.register(:value_object, Type::ValueObject)
ActiveRecord::Type.register(:value_object, Type::ValueObject)
ActiveModel::Type.register(:multiparam_date, Type::MultiparamDate)
ActiveModel::Type.register(:pence, Type::Pence)
ActiveRecord::Type.register(:pence, Type::Pence)
