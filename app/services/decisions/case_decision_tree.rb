module Decisions
  class CaseDecisionTree < BaseDecisionTree
    # rubocop:disable Metrics/MethodLength
    def destination
      case step_name
      when :urn
        after_urn
      when :case_type
        after_case_type
      when :has_codefendants
        after_has_codefendants
      when :add_codefendant
        edit_codefendants(add_blank: true)
      when :delete_codefendant
        edit_codefendants(add_blank: false)
      when :codefendants_finished
        # Next step when we have it
        show('/home', action: :index)
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end
    # rubocop:enable Metrics/MethodLength

    private

    def after_case_type
      edit('/steps/case/codefendants')
    end

    def after_urn
      edit('/steps/case/case_type')
    end

    def after_has_codefendants
      if form_object.has_codefendants.yes?
        edit(:codefendants)
      else
        show('/home', action: :index)
      end
    end

    def edit_codefendants(add_blank:)
      form_object.add_blank_codefendant if add_blank
      edit(:codefendants)
    end
  end
end
