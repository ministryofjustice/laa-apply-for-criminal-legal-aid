module CapitalAssessment
  class PropertyOwnersValidator < ActiveModel::Validator
    attr_reader :record

    Error = Struct.new(:attribute, :type)

    def validate(record)
      @record = record

      record.property_owners.each_with_index do |property_owner, index|
        add_indexed_errors(property_owner, index) unless property_owner.valid?
      end

      add_ownership_error unless valid_ownership_total?(record)
    end

    private

    def add_indexed_errors(property_owner, index)
      property_owner.errors.each do |error|
        add_error(property_owner, error, index)
      end
    end

    def indexed_attribute(index, attr)
      "property_owners-attributes[#{index}].#{attr}"
    end

    # `activemodel.errors.models.steps/capital/property_owner_fieldset_form.summary.x.y`
    def error_message(obj, error)
      I18n.t(
        "#{obj.model_name.i18n_key}.summary.#{error.attribute}.#{error.type}",
        scope: [:activemodel, :errors, :models]
      )
    end

    def add_error(property_owner, error, index)
      attr_name = indexed_attribute(index, error.attribute)

      record.errors.add(
        attr_name,
        error.type,
        message: error_message(property_owner, error), index: index + 1
      )

      # We define the attribute getter as it doesn't really exist
      record.define_singleton_method(attr_name) do
        property_owner.public_send(error.attribute)
      end
    end

    def add_ownership_error
      record.errors.add(
        :base,
        :invalid,
        message: error_message(record, Error.new(:base, :invalid))
      )
    end

    def valid_ownership_total?(record)
      percentage_ownerships = all_percentage_ownerships(record)

      percentage_ownerships.sum == 100
    end

    def all_percentage_ownerships(record)
      percentage_ownerships = record.property_owners.filter_map do |po|
        po.percentage_owned unless po.percentage_owned.nil?
      end

      percentage_ownerships << record.record.percentage_applicant_owned
      percentage_ownerships << record.record.percentage_partner_owned unless record.record.percentage_partner_owned.nil?

      percentage_ownerships
    end
  end
end
