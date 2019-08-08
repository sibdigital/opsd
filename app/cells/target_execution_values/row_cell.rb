module TargetExecutionValues
  class RowCell < ::RowCell
    include ::IconsHelper
    include ReorderLinksHelper

    def target_execution_value
      model
    end

    def project
      Target.find(model.target_id).project
    end

    def target?
      !Target.where(id: model.target_id).empty?
    end

    def year
      target_execution_value.year
    end

    def quarter
      target_execution_value.quarter
    end

    def value
      target_execution_value.value
    end

    def button_links
      [
        delete_link
      ]
    end

    def delete_link
      if User.current.allowed_to?(:manage_work_package_target_plan_values, @project)
        link_to(
          op_icon('icon icon-delete'),
          target_execution_value_path(id: target_execution_value, target_id: target_execution_value.target_id, project_id: project.identifier),
          method: :delete,
          data: { confirm: I18n.t(:text_are_you_sure) },
          title: t(:button_delete)
        )
      end
    end
  end
end
