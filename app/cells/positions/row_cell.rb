#-- encoding: UTF-8
# This file written by TAN
# 25/04/2019
module Positions
  class RowCell < ::RowCell
    include ::IconsHelper
    include ReorderLinksHelper

    def position
      model
    end

    def name
      link_to h(position.name), edit_position_path(position)
    end

    def button_links
      [
        delete_link
      ]
    end

    def delete_link
      link_to(
        op_icon('icon icon-delete'),
        position_path(position),
        method: :delete,
        data: { confirm: I18n.t(:text_are_you_sure) },
        title: t(:button_delete)
      )
    end
  end
end
