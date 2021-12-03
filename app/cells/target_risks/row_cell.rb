module TargetRisks
  class RowCell < ::RowCell
    include ::IconsHelper
    include ReorderLinksHelper

    def target_risk
      model
    end

    def target?
      !Target.where(id: model.target_id).empty?
    end

    def risk?
      !Risk.where(id: model.risk_id).empty?
    end

    def risk
      link_to(target_risk.risk.name || '', edit_tab_project_project_risk_path(target_risk.risk.project_id, target_risk.risk_id, :properties))
    end

    def solution_date
      target_risk.solution_date
    end

    def is_solved
      checkmark(target_risk.is_solved)
    end

    def row_css_id
      'row_' + target_risk.id.to_s
    end

    def row_css_class
      'risk_id_' + target_risk.risk.id.to_s
    end

    def button_links
      [
        edit_link,
        delete_link,
      ]
    end


    def edit_link
        '<div class="target-risk-edit icon icon-edit" style="cursor: pointer;float:left;" title="Изменить" data-id="'+target_risk.id.to_s+'"></div>'.html_safe
    end

    def delete_link
      content_tag( :div,
      link_to(
        op_icon('icon icon-delete'),
        target_risk_path(id: target_risk, target_id: target_risk.target_id, risk_id: target_risk.risk_id),
        method: :delete,
        data: { confirm: I18n.t(:text_are_you_sure) },
        title: t(:button_delete) #,
        #remote: true
      )
      )
    end
  end
end
