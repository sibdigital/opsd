#-- encoding: UTF-8
# This file written by TAN
# 25/04/2019
module Departs
  class RowCell < ::RowCell
    include ::IconsHelper
    include ReorderLinksHelper

    def depart
      model
    end

    def name
      link_to h(depart.name), edit_depart_path(depart)
    end

    def button_links
      [
        delete_link
      ]
    end

    def delete_link
      link_to(
        op_icon('icon icon-delete'),
        depart_path(depart),
        method: :delete,
        data: { confirm: I18n.t(:text_are_you_sure) },
        title: t(:button_delete)
      )
    end
  end
end
