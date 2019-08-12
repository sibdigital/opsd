#-- encoding: UTF-8
# This file written by TAN
# 25/04/2019
require_dependency 'organizations/row_cell'

module Organizations
  class TableCell < ::TableCell

    #columns_index :name
    #columns_choose :name

    def initial_sort
      %i[id asc]
    end


    def columns
      if action_name == 'index'
        return ['name', 'is_legal_entity', 'inn']
      end
      ['name', 'is_legal_entity', 'inn']
    end

    def inline_create_link
      if params[:action] == 'iogv'
      @org_type = Enumeration.find_by(name: "Орган исполнительной власти").id
      elsif params[:action] == 'counterparties'
        @org_type = Enumeration.find_by(name: "Контрагент").id
      elsif params[:action] == 'municipalities'
        @org_type = Enumeration.find_by(name: "Муниципальное образование").id
      end

      @parent_id = 0
      if params[:parent_id] != nil
        @parent_id = params[:parent_id]
      end

      link_to new_organization_path(:org_type => @org_type, :parent_id => @parent_id ),
              aria: { label: t(:button_add) },
              class: 'wp-inline-create--add-link',
              title: t(:button_add) do
        op_icon('icon icon-add')
      end

    end

    def inline_up_link
      @organizanion = Organization.find_by(id: params[:parent_id])
      if @organizanion == nil
        @parent_id = 0
      else  @parent_id = @organizanion.parent_id
      end
      link_to org_settings_path(:parent_id => @parent_id, :tab => params[:tab]),
              aria: { label: t(:button_up) },
              class: 'wp-inline-create--split-link',
              title: t(:button_up) do
        op_icon('icon-arrow-up2')
      end
    end


    def empty_row_message
      I18n.t :no_results_title_text
    end

    def row_class
      ::Organizations::RowCell
    end

    def headers
      [
        ['name', caption: Organization.human_attribute_name(:name)],
        ['is_legal_entity', caption: Organization.human_attribute_name(:is_legal_entity)],
        ['inn', caption: Organization.human_attribute_name(:inn)]
      ]
    end

    def header_options(name)
      {column: name, caption: Organization.human_attribute_name(name) }

    end

  end
end
