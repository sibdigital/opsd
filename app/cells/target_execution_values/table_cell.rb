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


    def initial_sort
      %i[id asc]
    end

    def sortable?
      false
    end

    def columns
      %i[id sort]
    end

    def inline_create_link

        link_to new_target_execution_value_path(project_id: project_id, target_id: target_id),
                aria: { label: t(:label_target_execution_values_new) },
                class: 'wp-inline-create--add-link',
                title: t(:label_target_execution_values_new) do
          op_icon('icon icon-add')
        end

    end

    def empty_row_message
      I18n.t :no_results_title_text
    end

    def row_class
      ::TargetExecutionValues::RowCell
    end

    def headers
      [
        ['id', caption: TargetExecutionValue.human_attribute_name(:id)],
        ['sort', caption: I18n.t(:label_sort)]
      ]
    end
  end
end
