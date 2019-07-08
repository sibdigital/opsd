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


#    def name
#        link_to h(target_execution_value.name), edit_target_execution_value_path(id: target_execution_value, target_id: target_execution_value.target_id, project_id: project.identifier)
#      end
    end

    def sort
        reorder_links 'target_execution_value',
                      { controller: 'target_execution_values', action: 'update', id: target_execution_value, target_id: target_execution_value.target_id, project_id: project.identifier },
                      method: :put
    end

    def button_links
      [
        delete_link
      ]
    end

    def delete_link
        link_to(
          op_icon('icon icon-delete'),
          target_execution_value_path(id: target_execution_value, target_id: target_execution_value.target_id, project_id: project.identifier),
          method: :delete,
          data: { confirm: I18n.t(:text_are_you_sure) },
          title: t(:button_delete)
        )

    end

end
