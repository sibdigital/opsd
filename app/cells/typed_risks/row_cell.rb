#-- encoding: UTF-8
# This file written by BBM
# 23/04/2019
module TypedRisks
  class RowCell < ::RowCell
    include ::IconsHelper
    include ::ColorsHelper
    include ReorderLinksHelper

    def risk
      model
    end

    def name
      link_to h(risk.name), edit_typed_risk_path(risk)
    end

    def possibility
      risk.possibility
    end

    def importance
      risk.importance
    end

    def color
      icon_for_color risk.color
    end

    def sort
      reorder_links('typed_risk', { action: 'update', id: risk }, method: :put)
    end

    def button_links
      [
        delete_link
      ]
    end

    def delete_link
      link_to(
        op_icon('icon icon-delete'),
        typed_risk_path(risk),
        method: :delete,
        data: { confirm: I18n.t(:text_are_you_sure) },
        title: t(:button_delete)
      )
    end
  end
end
