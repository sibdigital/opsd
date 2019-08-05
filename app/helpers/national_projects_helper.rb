module NationalProjectsHelper
  #xcc
  def render_tree(tree, pid, level)
    html = ''
    tree.each do |national_project|
      if national_project.parent_id == pid
        html = html + '<tr national-project-id="' + national_project.id.to_s + '" data-class-identifier="wp-row-' + national_project.id.to_s + '" class="wp-table--row wp--row wp-row-' + national_project.id.to_s + ' wp-row-' + national_project.id.to_s + '-table issue __hierarchy-group-' + national_project.parent_id.to_s + ' __hierarchy-root-' + national_project.id.to_s + '">'
        html = html + content_tag(:td, link_to(national_project.id, edit_national_project_path(id: national_project.id)))
        html = html + '<td></td>'
        tag_td = content_tag(:td) do
          # ('<span class="wp-table--hierarchy-indicator-icon" aria-hidden="true"></span>').html_safe +
          ('<span class="wp-table--hierarchy-span" style="width: ' + (level * 45).to_s + 'px;"></span>').html_safe +
            link_to(h(national_project.name), edit_national_project_path(id: national_project.id))
        end
        html = html + tag_td
        html = html + content_tag(:td, national_project.type)
        html = html + content_tag(:td, national_project.parent_id)
        html = html + content_tag(:td, national_project.leader)
        html = html + content_tag(:td, national_project.leader_position)
        html = html + content_tag(:td, national_project.curator)
        html = html + content_tag(:td, national_project.curator_position)
        html = html + content_tag(:td, national_project.start_date)
        html = html + content_tag(:td, national_project.due_date)
        html = html + content_tag(:td, national_project.description)
        html = html + content_tag(:td,
                                  link_to(op_icon('icon icon-add'),
                                          new_national_project_path(parent_id: national_project.id),
                                          aria: { label: t(:label_federal_projects) },
                                          class: 'wp-inline-create--add-link',
                                          title: t(:label_federal_projects))
        )
        html = html + content_tag(:td,
                                  link_to(
                                    op_icon('icon icon-delete'),
                                    national_project_path(id: national_project.id),
                                    method: :delete,
                                    data: { confirm: I18n.t(:text_are_you_sure) },
                                    title: t(:button_delete)
                                  ))
        html = html + render_tree(tree, national_project.id, level + 1)
        html = html + '</tr>'
      end
    end
    !html.empty? ? html.html_safe : ''
  end
end
