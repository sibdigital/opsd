# xcc
#
module TargetsHelper
  # def targets_tabs
  #   tabs = [
  #     {
  #       name: 'target',
  #       action: :edit_project,
  #       partial: 'targets/target',
  #       label: :label_target
  #     },
  #     {
  #       name: 'target_execution_values',
  #       action: :edit_project,
  #       partial: 'targets/target_execution_values',
  #       label: :label_target_execution_values
  #     }
  #   ]
  #   tabs.select { |tab| User.current.allowed_to?(tab[:action], @project) }
  # end

  def render_tree(tree, pid, level)
    html = ''
    tree.each do |target|
      if target.parent_id == pid
        html = html + '<tr data-work-package-id="' + target.id.to_s + '" data-class-identifier="wp-row-' + target.id.to_s + '" class="wp-table--row wp--row wp-row-' + target.id.to_s + ' wp-row-' + target.id.to_s + '-table issue __hierarchy-group-' + target.parent_id.to_s + ' __hierarchy-root-' + target.id.to_s + '">'
        html = html + content_tag(:td, link_to(target.id, edit_project_target_path(id: target.id)))
        html = html + '<td></td>'
        tag_td = content_tag(:td) do
          # ('<span class="wp-table--hierarchy-indicator-icon" aria-hidden="true"></span>').html_safe +
          ('<span class="wp-table--hierarchy-span" style="width: ' + (level * 45).to_s + 'px;"></span>').html_safe +
            link_to(h(target.name), edit_project_target_path(id: target.id))
        end
        html = html + tag_td
        html = html + content_tag(:td, target.target_status)
        html = html + content_tag(:td, target.target_type)
        html = html + content_tag(:td, target.measure_unit)
        html = html + content_tag(:td, target.basic_value)
        html = html + content_tag(:td, target.plan_value)
        html = html + content_tag(:td, target.is_approve)
        if User.current.allowed_to?(:manage_work_package_target_plan_values, @project)
          html = html + content_tag(:td,
                    link_to(op_icon('icon icon-add'),
                            new_project_target_path(parent_id: target.id),
                            aria: { label: t(:label_child_target_new) },
                            class: 'wp-inline-create--add-link',
                            title: t(:label_child_target_new))
          )
        html = html + content_tag(:td,
                   link_to(
                     op_icon('icon icon-delete'),
                     project_target_path(id: target.id),
                     method: :delete,
                     data: { confirm: I18n.t(:text_are_you_sure) },
                     title: t(:button_delete)
                   ))
        end
        html = html + render_tree(tree, target.id, level + 1)
        html = html + '</tr>'
      end
    end
    !html.empty? ? html.html_safe : ''
  end

  # def render_tree_ul(tree, pid)
  #   html = ''
  #   tree.each do |target|
  #     if target.parent_id == pid
  #       html = html + '<li>'
  #       #html = html + '<table><tbody><tr>'
  #       html = html + link_to(h(target.name), edit_project_target_path(id: target.id))
  #       html = html + content_tag(:div, link_to(target.id, edit_project_target_path(id: target.id)))
  #       html = html + '<td></td>'
  #       html = html + content_tag(:div, link_to(h(target.name), edit_project_target_path(id: target.id)))
  #       html = html + content_tag(:div, target.target_status)
  #       html = html + content_tag(:div, target.target_type)
  #       html = html + content_tag(:div, target.unit)
  #       html = html + content_tag(:div, target.basic_value)
  #       html = html + content_tag(:div, target.plan_value)
  #       html = html + content_tag(:div, link_to(
  #         op_icon('icon icon-add'),
  #         project_targets_path(:parent_id => target.id),
  #         title: t(:button_click_to_reveal)))
  #       html = html + content_tag(:div, link_to(
  #         op_icon('icon icon-delete'),
  #         project_target_path(id: target.id),
  #         method: :delete,
  #         data: {confirm: I18n.t(:text_are_you_sure)},
  #         title: t(:button_delete)))
  #
  #       html = html + render_tree_ul(tree, target.id)
  #       #html = html + '</tr></tbody></table>'
  #       html = html + '</li>'
  #     end
  #   end
  #   html.length !=0 ? ('<ul>' + html + '</ul>').html_safe : ''
  # end
end
