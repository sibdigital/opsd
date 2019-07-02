#-- encoding: UTF-8
# This file written by TAN
# 25/04/2019
require_dependency 'positions/row_cell'

module Positions
  class TableCell < ::TableCell

    def initial_sort
      %i[id asc]
    end


    def columns
      %i[name].tap do |default|

      end
    end

    def inline_create_link
      # необходимо объявить resources в route.rb
      link_to new_position_path(),
              aria: { label: t(:label_position_new) },
              class: 'wp-inline-create--add-link',
              title: t(:label_position_new) do
        op_icon('icon icon-add')
      end
    end

    def empty_row_message
      I18n.t :no_results_title_text
    end

    def row_class
      ::Positions::RowCell
    end

    def headers
      columns.map do |name|
        [name.to_s, header_options(name)]
      end
    end

    def header_options(name)
      { caption: Position.human_attribute_name(name) }
    end

    # def headers
    #   [
    #     ['name', 'Имя']
    #   ]
    #   # [
    #   #   ['name', caption: Position.human_attribute_name(:name)]
    #   # ].tap do |default|
    #   # end
    # end
  end
end
