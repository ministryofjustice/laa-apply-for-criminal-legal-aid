module TaskList
  class Task < BaseTaskRenderer
    def render
      tag.li class: 'app-task-list__item' do
        tag.span class: 'app-task-list__task-name' do
          link_to_if false, t!("tasklist.task.#{name}"), '#', aria: { describedby: tag_id }
        end.concat(
          ProgressTag.render(view, name: name, status: :not_applicable)
        )
      end
    end
  end
end
