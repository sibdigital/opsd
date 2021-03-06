require_dependency 'target_execution_values/row_cell'

module TargetExecutionValues
  class TableCell < ::TableCell

    def target_id
      options[:target_id]
    end

    def project_id
      options[:project_id]
    end

    def target?
      !Target.where(id: target_id).empty?
    end

    def columns
      ['year', 'quarter', 'value']
    end

    def inline_create_link
      # link_to("Добавить плановые значения",
      #         new_target_execution_value_path(target: Target.where(id: target_id), target_id: target_id, project_id: project_id), #project_id: project_id,
      #         aria: { label: t(:label_target_execution_values_new) },
      #         #remote: true,
      #         #class: 'wp-inline-create--add-link',
      #         title: t(:label_target_execution_values_new)
      # )

      # link_to new_target_execution_value_path(target_id: target_id, project_id: :project_id), #project_id: project_id,
      #         aria: { label: t(:label_target_execution_values_new) },
      #         #remote: true,
      #         class: 'wp-inline-create--add-link',
      #         title: t(:label_target_execution_values_new) do op_icon('icon icon-add')
      # end
      #('<div><span id="target-val-add" class="wp-inline-create--add-link icon icon-add"></span></div>').html_safe
    end

    def row_class
      ::TargetExecutionValues::RowCell
    end

    def headers
      [
        ['year', caption: TargetExecutionValue.human_attribute_name(:year)],
        ['quarter', caption: TargetExecutionValue.human_attribute_name(:quarter)],
        ['value', caption: TargetExecutionValue.human_attribute_name(:value)]
      ]
    end
  end
end
