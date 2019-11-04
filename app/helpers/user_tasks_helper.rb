module UserTasksHelper

  def children_options_for_select_wp(container, selected = nil)
    return container if String === container
    selected, disabled = extract_selected_and_disabled(selected).map do |r|
      Array(r).map(&:to_s)
    end
    container.map do |element|
      html_attributes = option_html_attributes(element)
      text, value = option_text_and_value(element).map(&:to_s)

      html_attributes[:selected] ||= option_value_selected?(value, selected)
      html_attributes[:disabled] ||= disabled && option_value_selected?(value, disabled)
      html_attributes[:value] = value
      html_attributes[:id] = element[1]
      tag_builder.content_tag_string(:option, text, html_attributes)
    end.join("\n").html_safe
  end

end
