require_dependency 'target_execution_values/row_cell'

module TargetExecutionValues
  class TableCell < ::TableCell

    def target_id
      options[:target_id]
    end

    # def project_id
    #   options[:project_id]
    # end
    #
     def target?
       !Target.where(id: target_id).empty?
     end



    def columns
#      %i[year sort]
      ['year', 'quarter', 'value']
    end

    def inline_create_link

        link_to new_target_execution_value_path( target_id: target_id), #project_id: project_id,
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
        ['year', caption: TargetExecutionValue.human_attribute_name(:year)],
        ['quarter', caption: TargetExecutionValue.human_attribute_name(:quarter)],
        ['value', caption: TargetExecutionValue.human_attribute_name(:value)]
#        ['sort', caption: I18n.t(:label_sort)]
      ]
    end
  end
end
