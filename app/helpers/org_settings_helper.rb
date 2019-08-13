#-- encoding: UTF-8
#+-tan 2019.04.25

require 'securerandom'

module OrgSettingsHelper
  include OpenProject::FormTagHelper

  def org_settings_tabs
    [
      { name: 'iogv', partial: 'org_settings/iogv', label: :label_iogv },
      { name: 'municipalities', partial: 'org_settings/municipalities', label: :label_municipalities },
      { name: 'counterparties', partial: 'org_settings/counterparties', label: :label_counterparties },
      { name: 'positions', partial: 'org_settings/positions', label: :label_positions }
    ]
  end
  def show_table_org (organisations, pid, level)
    html = ''
    organisations.each do |organisation|
      if organisation.parent_id == pid
        html = html + '<tr data-work-package-id="' + organisation.id.to_s + '" data-class-identifier="wp-row-' + organisation.id.to_s + '" class="wp-table--row wp--row wp-row-' + organisation.id.to_s + ' wp-row-' + organisation.id.to_s + '-table issue __hierarchy-group-' + organisation.parent_id.to_s + ' __hierarchy-root-' + organisation.id.to_s + '">'
        html = html + content_tag(:td, link_to(organisation.id, edit_organization_path(id: organisation.id)))
        tag_td = content_tag(:td) do
          # ('<span class="wp-table--hierarchy-indicator-icon" aria-hidden="true"></span>').html_safe +
          ('<span class="wp-table--hierarchy-span" style="width: ' + (level * 45).to_s + 'px;"></span>').html_safe +
            link_to(h(organisation.name), edit_organization_path(id: organisation.id))
        end
        html = html + tag_td
        # html = html+'<td>'
        # html = html + content_tag('input', nil,{type:'checkbox', checked: organisation.is_legal_entity, disabled: true})
        # html = html+'</td>'
        if organisation.is_legal_entity
          html = html + content_tag(:td, op_icon('icon icon-checkmark'))
        else
          html = html + '<td></td>'
        end
        html = html + content_tag(:td, organisation.inn)
        html = html + content_tag(:td,
                                  link_to(op_icon('icon icon-delete'),
                                          organization_path(id: organisation.id),
                                          method: :delete,
                                          data: { confirm: I18n.t(:text_are_you_sure) },
                                          title: t(:button_delete)
                                  ))
        html = html + show_table_org(organisations, organisation.id, level + 1)
        html = html + '</tr>'
      end
    end
    !html.empty? ? html.html_safe : ''
  end
end
