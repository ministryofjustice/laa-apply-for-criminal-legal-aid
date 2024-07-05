module Steps
  module BusinessResource
    extend ActiveSupport::Concern

    included do
      before_action :set_business
    end

    private

    def business_record
      @business
    end

    def set_business
      @business ||= businesses.find(params[:business_id])
    rescue ActiveRecord::RecordNotFound
      raise Errors::BusinessNotFound
    end

    def businesses
      @businesses ||= @subject.businesses
    end

    def decision_tree_class
      Decisions::SelfEmployedIncomeDecisionTree
    end
  end
end
