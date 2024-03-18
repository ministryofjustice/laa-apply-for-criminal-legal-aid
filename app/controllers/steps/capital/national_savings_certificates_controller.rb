module Steps
  module Capital
    class NationalSavingsCertificatesController < Steps::CapitalStepController
      def edit
        @form_object = NationalSavingsCertificatesForm.build(
          national_savings_certificate_record, crime_application: current_crime_application
        )
      end

      def update
        update_and_advance(
          NationalSavingsCertificatesForm,
          record: national_savings_certificate_record,
          as: :national_savings_certificates
        )
      end

      def destroy
        national_savings_certificate_record.destroy

        if national_savings_certificates.reload.any?
          redirect_to(edit_steps_capital_national_savings_certificates_summary_path,
                      success: t('.success_flash'))
        else
          # If this was the last remaining record, redirect to the national_savings_certificate type page
          redirect_to(edit_steps_capital_has_national_savings_certificates_path,
                      success: t('.success_flash'))
        end
      end

      def confirm_destroy
        @national_savings_certificate = national_savings_certificate_record
      end

      private

      def national_savings_certificate_record
        @national_savings_certificate_record ||= national_savings_certificates.find(
          params[:national_savings_certificate_id]
        )
      rescue ActiveRecord::RecordNotFound
        raise Errors::NationalSavingsCertificateNotFound
      end

      def national_savings_certificates
        @national_savings_certificates ||= current_crime_application.national_savings_certificates
      end

      def additional_permitted_params
        [:confirm_in_applicants_name]
      end
    end
  end
end
