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

    def row_css_id
      'row_' + target_execution_value.id.to_s
    end

    def row_css_class
      now = Date.today
      target_date = Date.parse((target_execution_value.quarter ? 1 : 31).to_s + '/' + (target_execution_value.quarter ? target_execution_value.quarter * 3 : 12).to_s + '/' + target_execution_value.year.to_s)
      if target_date <= now
        wp_target = Target.find(model.target_id)
                       .work_package_targets
                       .where(year: target_execution_value.year, quarter: target_execution_value.quarter)
        if wp_target.empty?
          'target_failed'
        elsif wp_target.first.value.nil?
          'target_failed'
        elsif wp_target.first.value < target_execution_value.value
          'target_failed'
        else
          'target_succeed'
        end
      end

    end

    def button_links
      [
        edit_link,
        delete_link
      ]
    end

    def edit_link
      if User.current.allowed_to?(:manage_work_package_target_plan_values, project)
        #tag("div", {class: 'target-val-edit icon icon-edit', style: "cursor: pointer;", title: t(:button_edit), data: { id: target_execution_value.id } })
        #content_tag(:div, class: 'target-val-edit icon icon-edit', style: "cursor: pointer;", title: t(:button_edit), data: { id: target_execution_value.id } )
        '<div class="target-val-edit icon icon-edit" style="cursor: pointer;float:left;" title="Изменить" data-id="'+target_execution_value.id.to_s+'"></div>'.html_safe
      end
    end

    def delete_link
      if User.current.allowed_to?(:manage_work_package_target_plan_values, project)
        content_tag( :div,
        link_to(
          op_icon('icon icon-delete'),
          target_execution_value_path(id: target_execution_value, target_id: target_execution_value.target_id, project_id: project.identifier),
          method: :delete,
          data: { confirm: I18n.t(:text_are_you_sure) },
          title: t(:button_delete) #,
          #remote: true
        )
        )
      end
    end
  end
end
