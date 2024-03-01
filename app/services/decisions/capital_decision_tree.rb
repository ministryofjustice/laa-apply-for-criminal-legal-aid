module Decisions
  class CapitalDecisionTree < BaseDecisionTree
    # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize
    def destination
      case step_name
      when :saving_type
        after_saving_type(form_object.saving)
      when :other_saving_type
        edit(:savings, saving_id: form_object.saving)
      when :savings
        edit(:savings_summary)
      when :savings_summary
        after_savings_summary
      when :property_type
        after_property_type(form_object.property)
      when :residential_property
        after_properties
      when :property_address
        # TODO: Route to property owner page once built
        after_property_address(form_object.record)
      when :property_owners, :properties
        # TODO: Route to assets list page once built
        after_property_owner
      when :add_property_owner
        after_add_property_owner
      when :delete_property_owner
        after_delete_property_owner
      when :premium_bonds
        # TODO: Route to national savings certificates once built
        edit('/steps/case/urn') # Placeholder to join up flow
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize

    private

    def after_saving_type(saving)
      return edit(:premium_bonds) unless saving

      edit(:savings, saving_id: saving)
    end

    def after_savings_summary
      return edit(:premium_bonds) if form_object.add_saving.no?

      edit(:other_saving_type)
    end

    def after_property_type(property)
      return edit(:saving_type) unless property

      edit("#{property.property_type}_property".to_sym, property_id: property)
    end

    def after_properties
      return edit(:property_address) if form_object.is_home_address.nil? || form_object.is_home_address.no?

      if form_object.has_other_owners.yes?
        property.property_owners.create! if incomplete_property_owners.blank?
        return edit(:property_owners, property_id: property)
      end
      # TODO: Route to appropriate property page loop once built
      edit(:saving_type) # Placeholder to join up flow
    end

    def after_property_address(property)
      if form_object.has_other_owners == 'yes'
        property.property_owners.create! if incomplete_property_owners.blank?
        return edit(:property_owners, property_id: property)
      end

      # TODO: Route to appropriate property page loop once built
      edit(:saving_type) # Placeholder to join up flow
    end

    def incomplete_property_owners
      property_owners.reject(&:complete?)
    end

    def after_property_owner
      edit(:saving_type) # Placeholder to join up flow
    end

    def after_add_property_owner
      property_owners << PropertyOwner.new if blank_owner_required?
      edit(:property_owners, property_id: property)
    end

    def after_delete_property_owner
      edit(:property_owners, property_id: property)
    end

    def property_owners
      @property_owners ||= property.property_owners
    end

    def property
      @property ||= form_object.record
    end

    def blank_owner_required?
      property.property_owners.map(&:name).exclude?(nil)
    end
  end
end
