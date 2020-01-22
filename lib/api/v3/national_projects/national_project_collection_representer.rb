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

require 'roar/decorator'
require 'roar/json'
require 'roar/json/collection'
require 'roar/json/hal'

module API
  module V3
    module NationalProjects
      class NationalProjectCollectionRepresenter < ::API::Decorators::UnpaginatedCollection
        include ::API::V3::Utilities::RoleHelper

        element_decorator ::API::V3::NationalProjects::NationalProjectRepresenter

        def initialize(models,
                       _params,
                       self_link,
                       current_user:,
                       global_role:)
          super(models,
                self_link,
                current_user: current_user)
          @current_user = current_user
          @global_role = global_role
        end

        collection :elements,
                   getter: ->(*) {
                     @elements = []
                     sort_list
                     #Rails.logger.info('repr: ' + represented.to_json)
                     #Rails.logger.info(@elements ? @elements.size() : 'empty mat proj')
                     @elements
                   },
                   exec_context: :decorator,
                   embedded: true

        private

        def sort_list
          represented.map do |nel|
            if nel.type == 'National'
              @elements << element_decorator.create(nel, current_user: current_user)
              represented.map do |fel|
                if fel.parent_id == nel.id
                  @elements << element_decorator.create(fel, current_user: current_user)
                end
              end
            end
          end
        end

        def render_tree(tree, pid)
          represented.map do |el|
            # Rails.logger.info("render_tree: #{el.id} PID: #{pid} el.parent_id= #{el.parent_id}")
            #Rails.logger.info('current_user: ' + @current_user.name + ' @global_role: ' + @global_role.to_s)
            if el.parent_id == pid
              @elements << element_decorator.create(el, current_user: current_user)
              render_tree(tree, el.id)
            end
          end
        end
      end
    end
  end
end
