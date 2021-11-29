require_dependency 'target_risks/row_cell'

module TargetRisks
  class TableCell < ::TableCell

    def target_id
      options[:target_id]
    end

    def risk_id
      options[:risk_id]
    end

    def target?
      !Target.where(id: target_id).empty?
    end

    def risk?
      !Target.where(id: risk_id).empty?
    end

    def columns
      ['risk']
    end

    def inline_create_link
    end

    def row_class
      ::TargetRisks::RowCell
    end

    def headers
      [
        # ['risk', caption: TargetRisk.human_attribute_name(:risk)]
        # TODO переделать
        ['risk', caption: "Риск"]
      ]
    end

  end
end
