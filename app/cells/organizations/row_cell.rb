#-- encoding: UTF-8
# This file written by TAN
# 25/04/2019
module Organizations
  class RowCell < ::RowCell
    include ::IconsHelper
    include ReorderLinksHelper

    def organization
      model
    end

    def name
      link_to h(organization.name), edit_organization_path(organization)
    end

    def choose
      #content_tag('span', "<input type='checkbox' name='ch#{organization.id}' value='#{organization.id}'>")
      content_tag('input', nil,{type:'checkbox', name:('ch'+ organization.id.to_s)})
    end

    def button_links
      [
        delete_link
      ]
    end

    def delete_link
      link_to(
        op_icon('icon icon-delete'),
        organization_path(organization),
        method: :delete,
        data: { confirm: I18n.t(:text_are_you_sure) },
        title: t(:button_delete)
      )
    end
  end
end
