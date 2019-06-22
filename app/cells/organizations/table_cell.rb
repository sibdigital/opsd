#-- encoding: UTF-8
# This file written by TAN
# 25/04/2019
require_dependency 'organizations/row_cell'

module Organizations
  class TableCell < ::TableCell

    #columns_index :name
    #columns_choose :choose, :name

    def initial_sort
      %i[id asc]
    end


    def columns
      if action_name == 'index'
        return ['name']
      elsif action_name == 'choose' || action_name == 'choose_from_depart'
        return ['choose','name']
      end
      ['name']
    end

    #def inline_create_link
      # необходимо объявить resources в route.rb
      # link_to new_organization_path(),
      #         aria: { label: t(:choose) },
      #         class: 'wp-inline-create--add-link',
      #         title: t(:choose) do
      #   op_icon('icon icon-add')
      # end
    #end

    def empty_row_message
      I18n.t :no_results_title_text
    end

    def row_class
      ::Organizations::RowCell
    end

    def headers
      columns.map do |name|
        [name.to_s, header_options(name)]
      end
    end

    def header_options(name)
      { caption: Organization.human_attribute_name(name) }
    end

    # def headers
    #   [
    #     ['name', 'Имя']
    #   ]
    #   # [
    #   #   ['name', caption: Organization.human_attribute_name(:name)]
    #   # ].tap do |default|
    #   # end
    # end
  end
end
