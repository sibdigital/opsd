#-- encoding: UTF-8
#+-tan 2019.04.25

require 'securerandom'

module OrganizationsHelper
  include OpenProject::FormTagHelper

  # def org_settings_tabs
  #   [
  #     { name: 'iogv', partial: 'org_settings/iogv', label: :label_iogv },
  #     { name: 'municipalities', partial: 'org_settings/municipalities', label: :label_municipalities },
  #     { name: 'counterparties', partial: 'org_settings/counterparties', label: :label_counterparties },
  #     { name: 'positions', partial: 'org_settings/positions', label: :label_positions }
  #   ]
  # end

  def show_table_org (organizations, pid, level)
    html = ''
    organizations.each do |organization|
      if organization.parent_id == pid
        html = html + '<tr data-work-package-id="' + organization.id.to_s + '" data-class-identifier="wp-row-' + organization.id.to_s + '" class="wp-table--row wp--row wp-row-' + organization.id.to_s + ' wp-row-' + organization.id.to_s + '-table issue __hierarchy-group-' + organization.parent_id.to_s + ' __hierarchy-root-' + organization.id.to_s + '">'
        html = html + content_tag(:td, link_to(organization.id, edit_organization_path(id: organization.id)))
        tag_td = content_tag(:td) do
          # ('<span class="wp-table--hierarchy-indicator-icon" aria-hidden="true"></span>').html_safe +
          ('<span class="wp-table--hierarchy-span" style="width: ' + (level * 45).to_s + 'px;"></span>').html_safe +
            link_to(h(organization.name), edit_organization_path(id: organization.id, org_type: organization.org_type))
        end
        html = html + tag_td
        # html = html+'<td>'
        # html = html + content_tag('input', nil,{type:'checkbox', checked: organization.is_legal_entity, disabled: true})
        # html = html+'</td>'
        if organization.is_legal_entity
          html = html + content_tag(:td, op_icon('icon icon-checkmark'))
        else
          html = html + '<td></td>'
        end
        html = html + content_tag(:td, organization.inn)
        html = html + content_tag(:td,
                                  link_to(op_icon('icon icon-delete'),
                                          organization_path(id: organization.id, org_type: organization.org_type),
                                          method: :delete,
                                          data: { confirm: I18n.t(:text_are_you_sure) },
                                          title: t(:button_delete)
                                  ))
        html = html + show_table_org(organizations, organization.id, level + 1)
        html = html + '</tr>'
      end
    end
    !html.empty? ? html.html_safe : ''
  end
end
