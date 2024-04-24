module CapitalAssessment
  class PropertyOwnershipValidator < ActiveModel::Validator
    attr_reader :form

    def validate(form)
      @form = form

      form.errors.add :percentage_applicant_owned, :invalid unless valid_ownership_total?(form)
      form.errors.add :percentage_partner_owned, :invalid if client_has_partner(form) && !valid_ownership_total?(form)
    end

    private

    def valid_ownership_total?(form)
      return true if other_owners?(form)

      percentage_ownerships = all_percentage_ownerships(form)
      percentage_ownerships.sum == 100
    end

    def all_percentage_ownerships(form)
      percentage_ownerships = []
      percentage_ownerships << form.percentage_applicant_owned unless form.percentage_applicant_owned.nil?
      percentage_ownerships << form.percentage_partner_owned unless form.percentage_partner_owned.nil?

      percentage_ownerships
    end

    def client_has_partner(form)
      form.crime_application.client_has_partner == 'yes'
    end

    def other_owners?(form)
      form.has_other_owners&.yes?
    end
  end
end
