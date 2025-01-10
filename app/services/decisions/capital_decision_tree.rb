module Decisions
  class CapitalDecisionTree < BaseDecisionTree # rubocop:disable Metrics/ClassLength
    include TypeOfMeansAssessment
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
      when :usual_property_details
        after_usual_property_details
      when :residential_property, :commercial_property, :land
        after_properties
      when :property_address
        after_property_address
      when :property_owners
        edit(:properties_summary)
      when :add_property_owner
        after_add_property_owner
      when :delete_property_owner
        edit(:property_owners, property_id: property)
      when :premium_bonds
        after_premium_bonds
      when :partner_premium_bonds
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
      when :trust_fund
        after_client_trust_fund
      when :partner_trust_fund
        after_trust_fund
      when :frozen_income_savings_assets_capital
        edit(:answers)
      when :answers
        edit('/steps/evidence/upload')
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
      return edit(:trust_fund) unless investment

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
      return edit(:trust_fund) if form_object.add_investment.no?

      edit(:other_investment_type)
    end

    def after_properties_summary
      return no_property_path if form_object.add_property.no?

      edit(:other_property_type)
    end

    def after_client_trust_fund
      if include_partner_in_means_assessment?
        edit(:partner_trust_fund)
      else
        after_trust_fund
      end
    end

    def after_trust_fund
      return edit(:frozen_income_savings_assets_capital) if income_frozen_assets_unanswered?

      edit(:answers)
    end

    def after_property_type(property)
      return no_property_path unless property

      redirect_path = if property.property_type == PropertyType::LAND.to_s
                        property.property_type.to_sym
                      else
                        :"#{property.property_type}_property"
                      end

      edit(redirect_path, property_id: property)
    end

    def no_property_path
      return edit(:usual_property_details) if crime_application.capital.usual_property_details_required?

      edit(:saving_type)
    end

    def after_usual_property_details
      if form_object.action == UsualPropertyDetailsAnswer::CHANGE_ANSWER.to_s
        return edit('/steps/client/residence_type')
      end

      edit(:residential_property,
           property_id: crime_application.properties.create!(property_type: PropertyType::RESIDENTIAL.to_s))
    end

    # TODO: : Fix nested conditions
    def after_properties
      return edit(:property_address) if form_object.is_home_address.nil? || form_object.is_home_address.no?

      if form_object.has_other_owners.yes?
        property_owners.create! if create_property_owner?
        return edit(:property_owners, property_id: property)
      end
      edit(:properties_summary)
    end

    def after_property_address
      if form_object.has_other_owners.to_s == YesNoAnswer::YES.to_s
        property_owners.create! if create_property_owner?
        return edit(:property_owners, property_id: property)
      end
      edit(:properties_summary)
    end

    def create_property_owner?
      incomplete_property_owners.empty? && property_owners.empty?
    end

    def incomplete_property_owners
      property_owners.reject(&:complete?)
    end

    def after_add_property_owner
      property_owners << PropertyOwner.new
      edit(:property_owners, property_id: property)
    end

    def property_owners
      @property_owners ||= property.property_owners
    end

    def property
      @property ||= form_object.record
    end

    def after_premium_bonds
      if include_partner_in_means_assessment?
        edit(:partner_premium_bonds)
      else
        edit(:has_national_savings_certificates)
      end
    end

    def income_frozen_assets_unanswered?
      form_object.crime_application.income.has_frozen_income_or_assets.nil?
    end

    def crime_application
      form_object.crime_application
    end
  end
end
