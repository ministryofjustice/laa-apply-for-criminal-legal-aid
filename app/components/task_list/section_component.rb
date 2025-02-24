module TaskList
  class SectionComponent < ViewComponent::Base
    attr_reader :section, :iteration

    def initialize(section:, section_iteration: nil)
      @section = section
      @iteration = section_iteration
      super
    end

    delegate :name, :tasks, :crime_application, to: :section

    def call
      safe_join([header_content, task_list_content])
    end

    private

    def task_list_content
      govuk_task_list(id_prefix:) do |task_list|
        task_list.with_items item_attributes
      end
    end

    def header_content
      tag.h2(class: 'govuk-heading-m', id: name) { section_title }
    end

    def section_title
      return section_name if iteration.blank?

      "#{section_number}. #{section_name}"
    end

    def section_number
      iteration.index + 1
    end

    def section_name
      I18n.t!(name, scope: 'tasklist.heading')
    end

    def id_prefix
      section_name.downcase.tr(' ', '-')
    end

    def item_attributes
      tasks.map do |task|
        {
          title: I18n.t!("tasklist.task.#{task.name}"),
          href: task.status.enabled? ? task.path : nil,
          status: StatusTag.new(status: task.status)
        }
      end
    end
  end
end
