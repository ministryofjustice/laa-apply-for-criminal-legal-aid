class ApplicationStruct < Dry::Struct
  transform_keys(&:to_sym)

  transform_types do |type|
    if type.default?
      type.constructor do |value|
        value.nil? ? Dry::Types::Undefined : value
      end
    else
      type
    end
  end

  include ActiveModel::Validations

  def to_partial_path
    self.class.name.split('::').last.underscore
  end
end
