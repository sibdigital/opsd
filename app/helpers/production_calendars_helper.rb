module ProductionCalendarsHelper
  # knm
  def work_days_check_box_tag (name, check, value = "1", checked = false, options = {})
    html_options = { "type" => "checkbox", "name" => name, "id" => sanitize_to_id(name), "value" => value }.update(options.stringify_keys)
    html_options["checked"] = "checked" if check
    tag :input, html_options
  end
end
