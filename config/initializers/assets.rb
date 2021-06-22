OpenProject::Application.configure do
  # Precompile additional assets.
  # application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
  config.assets.precompile += %w(
    favicon.ico
    openproject.css
    accessibility.css
    treetable.css
    admin_users.js
    autocompleter.js
    copy_issue_actions.js
    locales/*.js
    members_form.js
    members_select_boxes.js
    new_user.js
    project/responsible_attribute.js
    project/description_handling.js
    project/filters.js
    repository_navigation.js
    repository_settings.js
    select_list_move.js
    types_checkboxes.js
    work_packages.js
    vendor/ckeditor/ckeditor.*js
    vendor/enjoyhint.js
    bundles/openproject-legacy-app.js
    notify.js
    notifyme.js
    interactive_map.js
    project_interactive_map.js
    network.js
    strategic_map.js
    project_strategic_map.js
    plan_uploader_settings.js
    select_project.js
    form_by_radio.js
    select_wp_from_project.js
  )
end
