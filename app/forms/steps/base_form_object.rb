module Steps
  class BaseFormObject
    include ActiveModel::Model
    include ActiveModel::Attributes

    attr_accessor :crime_application,
                  :record

    # Initialize a new form object given an AR model, reading and setting
    # the attributes declared in the form object.
    # Most of the times, `record` is just the main DB table, but sometimes,
    # for example in has_one or has_many, `record` is a different table.
    def self.build(record, crime_application: nil)
      raise ArgumentError, "expected `ApplicationRecord`, got `#{record.class}`" unless record.is_a?(ApplicationRecord)

      attrs = record.slice(
        attribute_names
      ).merge!(
        crime_application: crime_application || record,
        record: record
      )

      new(attrs)
    end

    def save
      valid? && persist!
    end

    # This is a `save if you can, but it's fine if not` method, bypassing validations
    def save!
      persist!
    rescue StandardError
      false
    end

    def to_key
      # Intentionally returns nil so the form builder picks up only
      # the class name to generate the HTML attributes
      nil
    end

    def persisted?
      false
    end

    def new_record?
      true
    end

    # Add the ability to read/write attributes without calling their accessor methods.
    # Needed to behave more like an ActiveRecord model, where you can manipulate the
    # DB attributes making use of `self[:attribute]`
    def [](attr_name)
      instance_variable_get("@#{attr_name}".to_sym)
    end

    def []=(attr_name, value)
      instance_variable_set("@#{attr_name}".to_sym, value)
    end

    private

    # :nocov:
    def persist!
      raise 'Subclasses of BaseFormObject need to implement #persist!'
    end
    # :nocov:
  end
end
