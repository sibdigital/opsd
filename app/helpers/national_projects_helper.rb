module NationalProjectsHelper


  #knm
  def sort_table(all_projects)
    national_projects = all_projects.where(type: "National")
    federal_projects = all_projects.where(type: "Federal")
    html = ''
    national_projects.each do |national_project|
      html = html + '<tr national-project-id="' + national_project.id.to_s + '" data-class-identifier="wp-row-' + national_project.id.to_s + '" class="wp-table--row wp--row wp-row-' + national_project.id.to_s + ' wp-row-' + national_project.id.to_s + '-table issue __hierarchy-group-' + national_project.parent_id.to_s + ' __hierarchy-root-' + national_project.id.to_s + '">'
      html = html + content_tag(:td, link_to(national_project.id, edit_national_project_path(id: national_project.id)))
      tag_td = content_tag(:td) do
                # ('<span class="wp-table--hierarchy-indicator-icon" aria-hidden="true"></span>').html_safe +
        ('<span class="wp-table--hierarchy-span" style="width: ' + 0.to_s + 'px;"></span>').html_safe +
          link_to(h(national_project.name), edit_national_project_path(id: national_project.id))
      end
      html = html + tag_td
      # html = html + content_tag(:td, national_project.type)
      # html = html + content_tag(:td, national_project.parent_id)
      html = html + content_tag(:td, national_project.description)
      html = html + content_tag(:td, national_project.leader)
      html = html + content_tag(:td, national_project.leader_position)
      html = html + content_tag(:td, national_project.curator)
      html = html + content_tag(:td, national_project.curator_position)
      html = html + content_tag(:td, national_project.start_date.strftime("%d/%m/%Y"))
      html = html + content_tag(:td, national_project.due_date.strftime("%d/%m/%Y"))

      # html = html + content_tag(:td,
      #                           link_to(op_icon('icon icon-delete'),
      #                                   national_project_path(id: national_project.id),
      #                                   method: :delete,
      #                                   data: { confirm: I18n.t(:text_are_you_sure) },
      #                                   title: t(:button_delete)
      #                           ))
      html = html + '</tr>'
      federal_projects.each do |federal_project|
        if federal_project.parent_id === national_project.id
          html = html + '<tr federal_project-id="' + federal_project.id.to_s + '" data-class-identifier="wp-row-' + federal_project.id.to_s + '" class="wp-table--row wp--row wp-row-' + federal_project.id.to_s + ' wp-row-' + federal_project.id.to_s + '-table issue __hierarchy-group-' + federal_project.parent_id.to_s + ' __hierarchy-root-' + federal_project.id.to_s + '">'
          html = html + content_tag(:td, link_to(federal_project.id, edit_national_project_path(id: federal_project.id)))

          tag_td = content_tag(:td) do
            # ('<span class="wp-table--hierarchy-indicator-icon" aria-hidden="true"></span>').html_safe +
            ('<span class="wp-table--hierarchy-span" style="width: ' + 45.to_s + 'px;"></span>').html_safe +
              link_to(h(federal_project.name), edit_national_project_path(id: federal_project.id))
          end
          html = html + tag_td
          # html = html + content_tag(:td, federal_project.type)
          # html = html + content_tag(:td, federal_project.parent_id)
          html = html + content_tag(:td, federal_project.description)
          html = html + content_tag(:td, federal_project.leader)
          html = html + content_tag(:td, federal_project.leader_position)
          html = html + content_tag(:td, federal_project.curator)
          html = html + content_tag(:td, federal_project.curator_position)
          html = html + content_tag(:td, federal_project.start_date.strftime("%d/%m/%Y"))
          html = html + content_tag(:td, federal_project.due_date.strftime("%d/%m/%Y"))

          html = html + content_tag(:td,
                                    link_to(op_icon('icon icon-delete'),
                                            national_project_path(id: federal_project.id),
                                            method: :delete,
                                            data: { confirm: I18n.t(:text_are_you_sure) },
                                            title: t(:button_delete)
                                    ))
          html = html + '</tr>'
        end
      end
    end
    !html.empty? ? html.html_safe : ''
  end
end
