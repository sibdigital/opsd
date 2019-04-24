#-- encoding: UTF-8
# This file written by BBM
# 23/04/2019
require_dependency 'risks/row_cell'

module Risks
  class TableCell < ::TableCell

    def initial_sort
      %i[id asc]
    end

    def sortable?
      false
    end

    def with_colors
      model.colored?
    end

    def columns
      %i[name possibility importance sort].tap do |default|
        if with_colors
          default.insert 3, :color
        end
      end
    end

    def inline_create_link
      link_to new_risk_path(type: model.name),
              aria: { label: t(:label_typed_risk_new) },
              class: 'wp-inline-create--add-link',
              title: t(:label_typed_risk_new) do
        op_icon('icon icon-add')
      end
    end

    def empty_row_message
      I18n.t :no_results_title_text
    end

    def row_class
      ::Risks::RowCell
    end

    def headers
      [
        ['name', caption: Risk.human_attribute_name(:name)],
        ['possibility', caption: Risk.human_attribute_name(:possibility)],
        ['importance', caption: Risk.human_attribute_name(:importance)],
        ['sort', caption: I18n.t(:label_sort)]
      ].tap do |default|
        if with_colors
          default.insert 3, ['color', caption: Risk.human_attribute_name(:color)]
        end
      end
    end
  end
end
