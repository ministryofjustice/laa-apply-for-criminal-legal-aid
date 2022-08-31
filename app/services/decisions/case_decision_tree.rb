module Decisions
  class CaseDecisionTree < BaseDecisionTree
    def destination
      case step_name
      when :urn
        after_urn
      when :add_codefendant
        edit_codefendants
      when :codefendants_finished
        # Next step when we have it
        show('/home', action: :index)
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end

    private

    def after_urn
      show('/home', action: :index)
    end

    def edit_codefendants
      form_object.add_blank_codefendant
      edit(:codefendants)
    end
  end
end
