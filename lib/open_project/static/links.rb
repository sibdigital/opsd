#-- encoding: UTF-8
#-- copyright
# OpenProject is a project management system.
# Copyright (C) 2012-2018 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2017 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See docs/COPYRIGHT.rdoc for more details.
#++

module OpenProject
  module Static
    module Links
      class << self

        def help_link_overridden?
          OpenProject::Configuration.force_help_link.present?
        end

        def help_link
          OpenProject::Configuration.force_help_link.presence || static_links[:user_guides]
        end

        def [](name)
          links[name]
        end

        def links
          @links ||= static_links.merge(dynamic_links)
        end

        def has?(name)
          @links.key? name
        end

        private

        def dynamic_links
          dynamic = {
            help: {
              href: help_link,
              label: 'top_menu.help_and_support'
            }
          }

          if impressum_link = OpenProject::Configuration.impressum_link
            dynamic[:impressum] = {
              href: impressum_link,
              label: :label_impressum
            }
          end

          dynamic
        end

        def static_links
          {
            upsale: {
              href: '',
              label: 'homescreen.links.upgrade_enterprise_edition'
            },
            user_guides: {
              href: '/download_pdf',
              label: 'homescreen.links.user_guides'
            },
            configuration_guide: {
              href: '',
              label: 'links.configuration_guide'
            },
            glossary: {
              href: '',
              label: 'homescreen.links.glossary'
            },
            shortcuts: {
              href: '',
              label: 'homescreen.links.shortcuts'
            },
            boards: {
              href: '',
              label: 'homescreen.links.boards'
            },
            professional_support: {
              href: '',
              label: :label_professional_support
            },
            website: {
              href: '',
              label: 'label_openproject_website'
            },
            newsletter: {
              href: '',
              label: 'homescreen.links.newsletter'
            },
            blog: {
              href: '',
              label: 'homescreen.links.blog'
            },
            release_notes: {
              href: '',
              label: :label_release_notes
            },
            data_privacy: {
              href: '',
              label: :label_privacy_policy
            },
            report_bug: {
              href: '',
              label: :label_report_bug
            },
            roadmap: {
              href: '',
              label: :label_development_roadmap
            },
            crowdin: {
              href: '',
              label: :label_add_edit_translations
            },
            api_docs: {
              href: '',
              label: :label_api_documentation
            },
            text_formatting: {
              href: '',
              label: :setting_text_formatting
            },
            oauth_authorization_code_flow: {
              href: '',
              label: 'oauth.flows.authorization_code'
            },
            client_credentials_code_flow: {
              href: '',
              label: 'oauth.flows.client_credentials'
            },
            ldap_encryption_documentation: {
              href: '',
            },
            security_badge_documentation: {
              href: ''
            }
          }
        end
      end
    end
  end
end
