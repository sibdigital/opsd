require_dependency 'risk_characts/row_cell'

module RiskCharacts
  class TableCell < ::TableCell

    def risk_id
      options[:risk_id]
    end

    def project_id
      options[:project_id]
    end

    def project_risk?
      !ProjectRisk.where(id: risk_id).empty?
    end

    def typed_risk?
      !TypedRisk.where(id: risk_id).empty?
    end

    def initial_sort
      %i[id asc]
    end

    def sortable?
      false
    end

    def columns
      %i[name sort]
    end

    def inline_create_link
      if typed_risk?
        link_to new_typed_risk_charact_path(risk_id: risk_id, type: model.name),
                aria: { label: t(:label_risk_characts_new) },
                class: 'wp-inline-create--add-link',
                title: t(:label_risk_characts_new) do
          op_icon('icon icon-add')
        end
      elsif project_risk?
        link_to new_project_risk_charact_path(project_id: project_id, risk_id: risk_id, type: model.name),
                aria: { label: t(:label_risk_characts_new) },
                class: 'wp-inline-create--add-link',
                title: t(:label_risk_characts_new) do
          op_icon('icon icon-add')
        end
      end
    end

    def empty_row_message
      I18n.t :no_results_title_text
    end

    def row_class
      ::RiskCharacts::RowCell
    end

    def headers
      [
        ['name', caption: RiskCharact.human_attribute_name(:name)],
        ['sort', caption: I18n.t(:label_sort)]
      ]
    end
  end
end
