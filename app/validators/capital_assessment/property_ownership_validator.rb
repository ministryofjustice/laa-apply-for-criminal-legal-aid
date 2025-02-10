module CapitalAssessment
  class PropertyOwnershipValidator < ActiveModel::Validator
    attr_reader :form

    def validate(form)
      @form = form

      validate_applicant_ownership(form) unless other_owners?(form)
      validate_other_owners(form) if other_owners?(form)
      return unless form.include_partner_in_means_assessment? && !valid_ownership_total?(form)

      validate_partner_ownership(form) unless other_owners?(form)
    end

    private

    def validate_applicant_ownership(form)
      return if valid_ownership_total?(form)

      form.errors.add :percentage_applicant_owned, error_key(form)
    end

    def validate_partner_ownership(form)
      form.errors.add :percentage_partner_owned, error_key(form)
    end

    def validate_other_owners(form)
      return if valid_ownership_total?(form)

      form.errors.add :has_other_owners, error_key(form)
    end

    def valid_ownership_total?(form)
      percentage_ownerships = all_percentage_ownerships(form)

      return percentage_ownerships.sum < 100 if other_owners?(form)

      percentage_ownerships.sum == 100
    end

    def all_percentage_ownerships(form)
      percentage_ownerships = []
      percentage_ownerships << form.percentage_applicant_owned unless form.percentage_applicant_owned.nil?
      percentage_ownerships << form.percentage_partner_owned unless form.percentage_partner_owned.nil?

      percentage_ownerships
    end

    def other_owners?(form)
      form.has_other_owners&.yes?
    end

    def error_key(form)
      return :invalid_when_other_owners if other_owners?(form)

      :invalid
    end
  end
end
