module Decisions
  class CapitalDecisionTree < BaseDecisionTree # rubocop:disable Metrics/ClassLength
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
      when :properties_summary
        after_properties_summary
      when :property_type
        after_property_type(form_object.property)
      when :residential_property
        after_properties
      when :property_address
        after_property_address
      when :property_owners
        after_property_owner
      when :add_property_owner
        after_add_property_owner
      when :delete_property_owner
        after_delete_property_owner
      when :premium_bonds
        edit(:has_national_savings_certificates)
      when :has_national_savings_certificates
        after_has_national_savings_certificates
      when :national_savings_certificates
        edit(:national_savings_certificates_summary)
      when :national_savings_certificates_summary
        after_national_savings_certificates_summary
      when :investment_type
        after_investment_type(form_object.investment)
      when :other_investment_type
        edit(:investments, investment_id: form_object.investment)
      when :investments
        edit(:investments_summary)
      when :investments_summary
        after_investments_summary
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

    def after_investment_type(investment)
      return edit(:premium_bonds) unless investment

      edit(:investments, investment_id: investment)
    end

    def after_has_national_savings_certificates
      return edit(:investment_type) if form_object.has_national_savings_certificates.no?

      edit(:national_savings_certificates, national_savings_certificate_id: form_object.national_savings_certificate)
    end

    def after_national_savings_certificates_summary
      return edit(:investment_type) if form_object.add_national_savings_certificate.no?

      edit(:national_savings_certificates, national_savings_certificate_id: form_object.national_savings_certificate)
    end

    def after_investments_summary
      return edit('/steps/case/urn') if form_object.add_investment.no?

      edit(:other_investment_type)
    end

    def after_properties_summary
      return edit(:saving_type) if form_object.add_property.no?

      edit(:other_property_type)
    end

    def after_property_type(property)
      return edit(:saving_type) unless property

      edit(:"#{property.property_type}_property", property_id: property)
    end

    # TODO: : Fix nested conditions
    def after_properties
      return edit(:property_address) if form_object.is_home_address.nil? || form_object.is_home_address.no?

      if form_object.has_other_owners.yes?
        property_owners.create! if incomplete_property_owners.blank?
        return edit(:property_owners, property_id: property)
      end
      edit(:properties_summary)
    end

    def after_property_address
      if form_object.has_other_owners.to_s == YesNoAnswer::YES.to_s
        property_owners.create! if incomplete_property_owners.blank?
        return edit(:property_owners, property_id: property)
      end
      edit(:properties_summary)
    end

    def incomplete_property_owners
      property_owners.reject(&:complete?)
    end

    def after_property_owner
      edit(:properties_summary)
    end

    def after_add_property_owner
      property_owners << PropertyOwner.new
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
  end
end
