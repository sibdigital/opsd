module TypedTargetsHelper

  def render_tree_typed_targets(tree, pid, level)
    html = ''
    tree.each do |target|
      if target.parent_id == pid
        html = html + '<tr data-work-package-id="' + target.id.to_s + '" data-class-identifier="wp-row-' + target.id.to_s + '" class="wp-table--row wp--row wp-row-' + target.id.to_s + ' wp-row-' + target.id.to_s + '-table issue __hierarchy-group-' + target.parent_id.to_s + ' __hierarchy-root-' + target.id.to_s + '">'
        html = html + content_tag(:td, link_to(target.id, edit_typed_target_path(target.id)))
        tag_td = content_tag(:td) do
          ('<span class="wp-table--hierarchy-span" style="width: ' + (level * 45).to_s + 'px;"></span>').html_safe +
            link_to(h(target.name), edit_typed_target_path(target.id))
        end
        html = html + tag_td
        html = html + content_tag(:td, target.target_status)
        html = html + content_tag(:td, target.target_type)
        html = html + content_tag(:td, target.measure_unit)
        html = html + content_tag(:td, target.basic_value)
        html = html + content_tag(:td, target.plan_value)
        html = html + content_tag(:td, target.is_approve? ? icon_wrapper('icon icon-checkmark', I18n.t(:general_text_Yes)) : "" )
        html = html + render_tree_typed_targets(tree, target.id, level + 1)
        html = html + '</tr>'
      end
    end
    !html.empty? ? html.html_safe : ''
  end
end
