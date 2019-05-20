#-- encoding: UTF-8

# This file written by BBM
# 25/04/2019

module ControlLevelsHelper
  include OpenProject::FormTagHelper

  def typed_risks_multiselect
    content_tag(:span, class: 'form--field-container -vertical') do
      hidden_field_tag("choose_typed[]", '') +
        TypedRisk.all.map do |risk|
          content_tag(:label, class: 'form--label-with-check-box') do
            styled_check_box_tag("choose_typed[]", risk.id) + risk.name
          end
        end.join.html_safe
    end
  end
end
