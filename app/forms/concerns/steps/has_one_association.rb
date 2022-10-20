module Steps
  module HasOneAssociation
    extend ActiveSupport::Concern

    class_methods do
      attr_accessor :association_name, :through_association

      def build(crime_application)
        super(
          associated_record(crime_application), crime_application:
        )
      end

      # Return the record if already exists, or initialise a blank one
      def associated_record(crime_application)
        parent = if through_association
                   # :nocov: enable coverage once we use this in any form
                   existing_or_build(crime_application, through_association)
                   # :nocov:
                 else
                   crime_application
                 end

        existing_or_build(parent, association_name)
      end

      def existing_or_build(parent, name)
        parent.public_send(name) || parent.public_send("build_#{name}")
      end

      def has_one_association(name, through: nil)
        self.association_name = name
        self.through_association = through

        define_method(name) do
          @_assoc ||= self.class.associated_record(crime_application)
        end

        alias_method :kase, :case if name == :case
      end
    end
  end
end
