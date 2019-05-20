module RiskCharacts
  class RowCell < ::RowCell
    include ::IconsHelper
    include ReorderLinksHelper

    def risk_charact
      model
    end

    def project
      ProjectRisk.find(model.risk_id).project
    end

    def project_risk?
      !ProjectRisk.where(id: model.risk_id).empty?
    end

    def typed_risk?
      !TypedRisk.where(id: model.risk_id).empty?
    end

    def name
      if typed_risk?
        link_to h(risk_charact.name), edit_typed_risk_charact_path(id: risk_charact, risk_id: risk_charact.risk_id)
      elsif project_risk?
        link_to h(risk_charact.name), edit_project_risk_charact_path(id: risk_charact, risk_id: risk_charact.risk_id, project_id: project.identifier)
      end
    end

    def sort
      if typed_risk?
        reorder_links 'risk_charact',
                      { controller: 'typed_risk_characts', action: 'update', id: risk_charact, risk_id: risk_charact.risk_id },
                      method: :put
        #reorder_links('risk_charact', url: typed_risk_characts_path(risk_id: risk_charact.risk_id), method: :put)
      elsif project_risk?
        reorder_links 'risk_charact',
                      { controller: 'project_risk_characts', action: 'update', id: risk_charact, risk_id: risk_charact.risk_id, project_id: project.identifier },
                      method: :put
      end
    end

    def button_links
      [
        delete_link
      ]
    end

    def delete_link
      if typed_risk?
        link_to(
          op_icon('icon icon-delete'),
          typed_risk_charact_path(id: risk_charact, risk_id: risk_charact.risk_id),
          method: :delete,
          data: { confirm: I18n.t(:text_are_you_sure) },
          title: t(:button_delete)
        )
      elsif project_risk?
        link_to(
          op_icon('icon icon-delete'),
          project_risk_charact_path(id: risk_charact, risk_id: risk_charact.risk_id, project_id: project.identifier),
          method: :delete,
          data: { confirm: I18n.t(:text_are_you_sure) },
          title: t(:button_delete)
        )
      end
    end
  end
end
