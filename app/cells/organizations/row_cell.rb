#-- encoding: UTF-8
# This file written by xcc
# 24/06/2019
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

    def is_legal_entity
      content_tag('input', nil,{type:'checkbox', checked: organization.is_legal_entity, disabled: true})
    end

    def inn
      organization.inn
    end

    def custom_field_formula

    end

    def choose
      #content_tag('span', "<input type='checkbox' name='ch#{organization.id}' value='#{organization.id}'>")
      content_tag('input', nil,{type:'checkbox', name:('ch'+ organization.id.to_s)})
    end

    def button_links
      [
        inline_create_link,
        delete_link
      ]
    end

    def inline_create_link

      link_to organization_path(:parent_id => organization.id, :tab => params[:tab]),
              aria: { label: t(:button_click_to_reveal) },
              class: 'wp-inline-create--add-link',
              title: t(:button_click_to_reveal) do
       op_icon('icon icon-add')
      end
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
