#-- encoding: UTF-8
# This file written by xcc
# 05/07/2019
module Targets
  class RowCell < ::RowCell
    include ::IconsHelper
    include ReorderLinksHelper

    def target
      model
    end

    def name
      link_to h(target.name), edit_project_target_path(id: target.id)

#       target.name
    end

    def status
      target.status
    end

    def type
      target.type
    end

    def unit
      target.unit
    end

    def basic_value
      target.basic_value
    end

    def plan_value
      target.plan_value
    end

    def comment
      target.comment
    end

    def project
      target.project
    end


    def button_links
      [
        delete_link
      ]
    end

    def delete_link
      link_to(
        op_icon('icon icon-delete'),
#        project_targets_path(target.id),
        project_target_path(id: target.id),
        method: :delete,
        data: { confirm: I18n.t(:text_are_you_sure) },
        title: t(:button_delete)
      )
    end
  end
end
