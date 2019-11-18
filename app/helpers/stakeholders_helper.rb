module StakeholdersHelper

  def sort_table(all_projects)
    national_projects = all_projects.where(type: "National")
    federal_projects = all_projects.where(type: "Federal")
    html = ''
    national_projects.each do |national_project|
      html = html + '<tr id="' + national_project.id.to_s + '" national-project-id="' + national_project.id.to_s + '" data-class-identifier="wp-row-' + national_project.id.to_s + '" class="hide-head wp-table--row wp--row wp-row-' + national_project.id.to_s + ' wp-row-' + national_project.id.to_s + '-table issue __hierarchy-group-' + national_project.parent_id.to_s + ' __hierarchy-root-' + national_project.id.to_s + ' ">'
      html = html + content_tag(:td, link_to(national_project.id, edit_national_project_path(id: national_project.id)))
      tag_td = content_tag(:td) do
                # ('<span class="wp-table--hierarchy-indicator-icon" aria-hidden="true"></span>').html_safe +
        ('<span id="' + national_project.id.to_s + '" class="wp-table--hierarchy-span" style="width: ' + 25.to_s + 'px;">▼</span>').html_safe +
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
          html = html + '<tr id="' + national_project.id.to_s + '" national-project-id="' + national_project.id.to_s + '" federal_project-id="' + federal_project.id.to_s + '" data-class-identifier="wp-row-' + federal_project.id.to_s + '" class="hide-section wp-table--row wp--row wp-row-' + federal_project.id.to_s + ' wp-row-' + federal_project.id.to_s + '-table issue __hierarchy-group-' + federal_project.parent_id.to_s + ' __hierarchy-root-' + federal_project.id.to_s + '">'
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

  # def update_stakeholder_org(user_id, org_id)
  #   # sth_list = StakeholderUser.where(:user_id=>user_id).all
  #   sth = StakeholderUser.where(:user_id=>user_id).first
  #
  #   # sth_list.each do |sth|
  #   # StakeholderOrganization.where(:organization_id => sth.organization_id).update(:cabinet=>"1")
  #   old_sth_org_id = sth.organization_id
  #
  #   # if StakeholderOrganization.where(:organization_id=>old_sth_org_id, :project_id=>sth.project_id)
  #   # цикл по всем проектам
  #   # Member.where(user_id: user_id).each do |member|
  #   #   # if StakeholderOrganization.where(:organization_id=>org_id, :project_id=>sth.project_id).count == 0
  #   #     # в проекте только 1 участник из такой орг-ции
  #   #     orgs = StakeholderUser.where(:organization_id=>sth.organization_id, :project_id=>member.project_id)
  #   #     if orgs.count == 1
  #   #       # update
  #   #       old_org = StakeholderOrganization.where(:organization_id=>org_id, :project_id=>member.project_id)
  #   #       if old_org.count == 0
  #   #         orgs.update(:organization_id=>org_id, :name => Organization.find(org_id).name)
  #   #       else
  #   #         old_org.delete_all
  #   #       end
  #   #     else
  #   #       # insert new
  #   #       new_sth = StakeholderOrganization.new
  #   #       new_sth.organization_id = org_id
  #   #       new_sth.project_id = member.project_id
  #   #       new_sth.name = Organization.find(org_id).name
  #   #       new_sth.save!
  #   #
  #   #       # delete old
  #   #       if StakeholderUser.where(:organization_id=>sth.organization_id,
  #   #                                        :project_id=>member.project_id).count == 1
  #   #         StakeholderOrganization.where(:organization_id=>sth.organization_id,
  #   #                                     :project_id=>member.project_id).delete_all
  #   #       end
  #   #     end
  #   #   # end
  #   # end
  #
  #   # обновляем
  #   StakeholderUser.where(:user_id=>user_id).update(:organization_id => org_id)
  #
  # end

  def get_stakeholders(project_id)
    sth_users = []
    sth_orgs = []
    members = Member.where(:project_id=>project_id).all
    members.each do |member|
      user = User.find(member.user_id)

      u = []
      u = Hash['user_id'=>user.id,
                                'organization_id'=> user.organization_id,
                                'name'=> user.name,
                                'phone_wrk'=> user.phone_wrk,
                                'phone_wrk_add'=> user.phone_wrk_add,
                                'phone_mobile'=> user.phone_mobile,
                                'mail_add'=> user.mail_add,
                                'address'=> user.address,
                                'cabinet'=> user.cabinet ]

      sth_users.push u

      if user.organization_id.present?
        org = Organization.find(user.organization_id)
        if org.present?
          o = []
          o = Hash["organization_id", org.id, "name", org.name]
          sth_orgs.push o
        end
      end
    end

    return sth_users, sth_orgs.uniq

  end

end
