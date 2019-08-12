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
  def show_table_org (organisations)
    html = ''
    organisations.each do |organisation|
      html = html + '<tr national-project-id="' + organisation.id.to_s + '" data-class-identifier="wp-row-' + organisation.id.to_s + '" class="wp-table--row wp--row wp-row-' + organisation.id.to_s + ' wp-row-' + organisation.id.to_s + '-table issue __hierarchy-group-' + organisation.parent_id.to_s + ' __hierarchy-root-' + organisation.id.to_s + '">'
      html = html + content_tag(:td, link_to(organisation.id, edit_organization_path(id: organisation.id)))
      tag_td = content_tag(:td) do
        # ('<span class="wp-table--hierarchy-indicator-icon" aria-hidden="true"></span>').html_safe +
        ('<span class="wp-table--hierarchy-span" style="width: ' + 0.to_s + 'px;"></span>').html_safe +
          link_to(h(organisation.name), edit_organization_path(id: organisation.id))
      end
      html = html + tag_td
      # html = html + content_tag(:td, national_project.type)
      # html = html + content_tag(:td, national_project.parent_id)
      html = html + content_tag(:td, organisation.is_legal_entity)
      html = html + content_tag(:td, organisation.inn)
      html = html + content_tag(:td,
                                link_to(op_icon('icon icon-delete'),
                                        organization_path(id: organisation.id),
                                        method: :delete,
                                        data: { confirm: I18n.t(:text_are_you_sure) },
                                        title: t(:button_delete)
                                ))
      html = html + '</tr>'
    end
    !html.empty? ? html.html_safe : ''
  end
end
