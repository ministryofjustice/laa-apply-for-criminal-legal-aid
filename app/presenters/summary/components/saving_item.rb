module Summary
  module Components
    class SavingItem < ViewComponent::Base
       with_collection_parameter :saving

       def initialize(saving:, saving_counter:)
          @saving = saving
          @saving_counter = saving_counter
       end

      def call
        govuk_summary_card(title:) do |card|
          card.with_action { status_tag } unless saving.complete?
          card.with_action { change_link } 

          card.with_summary_list do |list|
            rows.each do |drow|
              list.with_row do |row|
                row.with_key text: I18n.t("helpers.objects.savings.#{drow.question}")
                row.with_value text: drow.value
              end
            end
          end
        end
      end

      private

      def details
        %i[
        provider_name
        sort_code
        account_number
        is_overdrawn
        are_wages_paid_into_account
        account_holder
        ]
      end

      attr_reader :saving, :saving_counter

      def title
        "#{saving.saving_type.humanize} #{saving_counter + 1}"
      end

      def change_link
        govuk_link_to("Change", edit_steps_capital_savings_path(saving.crime_application, saving_id: saving) )
      end

      def status_tag
        govuk_tag(text: :incomplete, colour: 'red')
      end

      def rows
        details.map {|d| Components::FreeTextAnswer.new(d, saving.send(d)) }
      end
    end
  end
end
