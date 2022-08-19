module TaskList
  class Section < BaseRenderer
    attr_reader :tasks, :index

    def initialize(crime_application, name:, tasks:, index:)
      super(crime_application, name: name)

      @tasks = tasks
      @index = index
    end

    def render
      tag.li do
        safe_join(
          [section_header, section_tasks]
        )
      end
    end

    def items
      @items ||= tasks.map { |name| Task.new(crime_application, name: name) }
    end

    private

    def section_header
      tag.h2 class: 'app-task-list__section' do
        tag.span class: 'app-task-list__section-number' do
          "#{index}."
        end.concat t!("tasklist.heading.#{name}")
      end
    end

    def section_tasks
      tag.ul class: 'app-task-list__items' do
        safe_join(
          items.map(&:render)
        )
      end
    end
  end
end
