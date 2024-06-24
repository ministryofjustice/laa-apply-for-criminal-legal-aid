module Steps
  module Income
    module Partner
      class OtherWorkBenefitsController < Steps::Income::Client::OtherWorkBenefitsController
        private

        def advance_as
          :partner_other_work_benefits
        end

        def form_name
          Steps::Income::Partner::OtherWorkBenefitsForm
        end
      end
    end
  end
end
