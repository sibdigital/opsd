module OpenProject::LdapGroups
  class Engine < ::Rails::Engine
    engine_name :openproject_ldap_groups

    include OpenProject::Plugins::ActsAsOpEngine

    patches %i[AuthSource Group]
  end
end
