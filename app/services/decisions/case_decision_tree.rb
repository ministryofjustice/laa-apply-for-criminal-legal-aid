module Decisions
  class CaseDecisionTree < BaseDecisionTree
    # rubocop:disable Metrics/MethodLength
    def destination
      case step_name
      when :urn
        edit(:case_type)
      when :case_type
        edit(:has_codefendants)
      when :has_codefendants
        after_has_codefendants
      when :add_codefendant
        edit_codefendants(add_blank: true)
      when :delete_codefendant
        edit_codefendants
      when :codefendants_finished
        # Next step when we have it
        show('/home', action: :index)
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end
    # rubocop:enable Metrics/MethodLength

    private

    def after_has_codefendants
      if form_object.has_codefendants.yes?
        edit_codefendants
      else
        show('/home', action: :index)
      end
    end

    def edit_codefendants(add_blank: false)
      codefendants = form_object.case.codefendants
      codefendants.create! if add_blank || codefendants.empty?

      edit(:codefendants)
    end
  end
end
