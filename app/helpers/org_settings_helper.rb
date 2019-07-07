#-- encoding: UTF-8
#+-tan 2019.04.25

require 'securerandom'

module OrgSettingsHelper
  include OpenProject::FormTagHelper

  def org_settings_tabs
    [
      { name: 'iogv', partial: 'org_settings/iogv', label: :label_iogv },
      { name: 'municipalities', partial: 'org_settings/municipalities', label: :label_municipalities },
      { name: 'counterparties', partial: 'org_settings/counterparties', label: :label_counterparties },
      { name: 'positions', partial: 'org_settings/positions', label: :label_positions }
    ]
  end

end
