module TaskList
  class Task < BaseRenderer
    delegate :status, to: :task
    delegate :completed?, to: :status

    def render
      tag.li class: 'app-task-list__item' do
        safe_join(
          [task_name, status_tag]
        )
      end
    end

    private

    def task_name
      tag.span class: 'app-task-list__task-name' do
        task_link
      end
    end

    def task_link
      if status.enabled?
        tag.a t!("tasklist.task.#{name}"), href: task.path, aria: { describedby: tag_id }
      else
        t!("tasklist.task.#{name}")
      end
    end

    def status_tag
      StatusTag.new(crime_application, name: name, status: status).render
    end

    def task
      @task ||= Tasks::BaseTask.build(
        name, crime_application: crime_application
      )
    end
  end
end
