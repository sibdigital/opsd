#-- encoding: UTF-8
# This file written by XCC
# 05/07/2019
require_dependency 'targets/row_cell'

module Targets
  class TableCell < ::TableCell


    def initial_sort
      %i[id asc]
    end


    def columns
      if action_name == 'index'

        return ['name', 'status', 'typen', 'unit', 'basic_value', 'plan_value', 'comment', 'project_id']
      end
      if action_name == 'show'
        return ['name', 'status', 'typen', 'unit', 'basic_value', 'plan_value', 'comment', 'project_id']
      end

      ['name', 'status', 'typen', 'unit', 'basic_value', 'plan_value', 'comment', 'project_id']
    end

    def inline_create_link
      @project = Project.find(params[:project_id])
      link_to new_project_target_path(@project),
              aria: { label: t(:button_add) },
              class: 'wp-inline-create--add-link',
              title: t(:button_add) do
        op_icon('icon icon-add')
      end

    end


    def empty_row_message
      I18n.t :no_results_title_text
    end

    def row_class
      ::Targets::RowCell
    end

    def headers
      [
        ['name', caption: Target.human_attribute_name(:name)],
        ['status', caption: Target.human_attribute_name(:status)],
        ['typen', caption: Target.human_attribute_name(:typen)],
        ['unit', caption: Target.human_attribute_name(:unit)],
        ['basic_value', caption: Target.human_attribute_name(:basic_value)],
        ['plan_value', caption: Target.human_attribute_name(:plan_value)],
        ['comment', caption: Target.human_attribute_name(:comment)],
        ['project_id', caption: Target.human_attribute_name(:project_id)]
      ]
    end

    def header_options(name)
      {column: name, caption: Target.human_attribute_name(name) }

    end

  end
end
