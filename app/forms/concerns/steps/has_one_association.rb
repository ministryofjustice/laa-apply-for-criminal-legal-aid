module Steps
  module HasOneAssociation
    extend ActiveSupport::Concern

    class_methods do
      attr_accessor :association_name

      def build(crime_application)
        super(
          associated_record(crime_application),
          crime_application: crime_application
        )
      end

      # Return the record if already exists, or initialise a blank one
      def associated_record(parent)
        parent.public_send(association_name) || parent.public_send("build_#{association_name}")
      end

      private

      def has_one_association(name)
        self.association_name = name

        define_method(name) do
          @_assoc ||= self.class.associated_record(crime_application)
        end
      end
    end
  end
end
