module CapitalAssessment
  class PropertyOwnershipValidator < ActiveModel::Validator
    attr_reader :form

    def validate(form)
      @form = form

      other_owners? ? validate_other_owners : validate_ownership
    end

    private

    def validate_ownership
      return if valid_ownership_total?

      form.errors.add :percentage_applicant_owned, error_key
      form.errors.add :percentage_partner_owned, :invalid if partner_included?
    end

    def validate_other_owners
      form.errors.add :has_other_owners, :invalid_when_other_owners unless valid_ownership_total?
    end

    def valid_ownership_total?
      total_percentages = all_percentage_ownerships.sum
      other_owners? ? total_percentages < 100 : total_percentages == 100
    end

    def all_percentage_ownerships
      percentage_ownerships = []
      percentage_ownerships << form.percentage_applicant_owned unless form.percentage_applicant_owned.nil?
      percentage_ownerships << form.percentage_partner_owned unless form.percentage_partner_owned.nil?

      percentage_ownerships
    end

    def partner_included?
      form.include_partner_in_means_assessment?
    end

    def other_owners?
      form.has_other_owners&.yes?
    end

    def error_key
      partner_included? ? :invalid : :invalid_with_no_partner
    end
  end
end
