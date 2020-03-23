
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

module API
  module V3
    module WorkPackages
      class CompactWorkPackageRepresenter < ::API::Decorators::Single
        include API::Decorators::LinkedResource
        include API::Caching::CachedRepresenter

        cached_representer key_parts: %i(project),
                           disabled: false

        def initialize(model, current_user:, embed_links: false)
          model = model

          super
        end

        self_link

        property :id,
                 render_nil: true

        property :subject,
                 render_nil: true

        associated_resource :project

        def _type
          'WorkPackage'
        end

        def json_cache_key
          ['API',
           'V3',
           'WorkPackages',
           'WorkPackageRepresenter',
           'json',
           I18n.locale,
           represented.cache_checksum,
           Setting.work_package_done_ratio,
           Setting.feeds_enabled?]
        end
      end
    end
  end
end
