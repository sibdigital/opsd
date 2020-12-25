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
require 'roar/json/hal'

module API
  module V3
    module WorkPackages
      module Schema
        class WorkPackageSchemaRepresenter < ::API::Decorators::SchemaRepresenter
          include API::Caching::CachedRepresenter
          extend ::API::V3::Utilities::CustomFieldInjector::RepresenterClass

          custom_field_injector type: :schema_representer

          class << self
            def represented_class
              WorkPackage
            end

            def attribute_group(property)
              lambda do
                key = property.to_s.gsub /^customField/, "custom_field_"
                attribute_group_map key
              end
            end

            # override the various schema methods to include

            def schema(property, *args)
              opts, = args
              opts[:attribute_group] = attribute_group property

              super property, **opts
            end

            def schema_with_allowed_link(property, *args)
              opts, = args
              opts[:attribute_group] = attribute_group property

              super property, **opts
            end

            def schema_with_allowed_collection(property, *args)
              opts, = args
              opts[:attribute_group] = attribute_group property

              super property, **opts
            end
          end

          def initialize(schema, self_link, context)
            @base_schema_link = context.delete(:base_schema_link) || nil
            @show_lock_version = !context.delete(:hide_lock_version)
            @action = context.delete(:action) || :update
            super(schema, self_link, context)
          end

          def json_cache_key
            parts = ['api/v3/work_packages/schemas',
                     project_type_cache_key,
                     I18n.locale,
                     project_cache_key,
                     type_cache_key,
                     custom_field_cache_key]

            OpenProject::Cache::CacheKey.key(parts)
          end

          link :baseSchema do
            { href: @base_schema_link } if @base_schema_link
          end

          property :attribute_groups,
                   type: "[]String",
                   as: "_attributeGroups",
                   exec_context: :decorator

          schema :lock_version,
                 type: 'Integer',
                 name_source: ->(*) { I18n.t('api_v3.attributes.lock_version') },
                 show_if: ->(*) { @show_lock_version }

          schema :id,
                 type: 'Integer'

          schema :subject,
                 type: 'String',
                 min_length: 1,
                 max_length: 255,
                 writable: ->(*) { current_user_allowed_to(:edit_subject, context: represented.project) }

          schema :sed_href,
                 type: 'Href',
                 required: false,
                 min_length: 1,
                 max_length: 255,
                 writable: ->(*) { current_user_allowed_to(:edit_sed_href, context: represented.project) }

          schema :days,
                 type: 'Integer',
                 required: false
          # )
          schema :topic_href,
                 type: 'Href',
                 required: false,
                 min_length: 1,
                 max_length: 255

          #zbd(
          schema :result_agreed,
                 type: 'Boolean',
                 required: false,
                 show_if: ->(*) { !represented.milestone? },
                 writable: ->(*) { current_user_allowed_to(:edit_result_agreed, context: represented.project) }
          # )

          schema :description,
                 type: 'Formattable',
                 required: false,
                 writable: ->(*) { current_user_allowed_to(:edit_description, context: represented.project) }

          schema :start_date,
                 type: 'Date',
                 required: false,
                 show_if: ->(*) { !represented.milestone? },
                 writable: ->(*) { current_user_allowed_to(:edit_start_date, context: represented.project) }

          schema :due_date,
                 type: 'Date',
                 required: false,
                 show_if: ->(*) { !represented.milestone? },
                 writable: ->(*) { current_user_allowed_to(:edit_due_date, context: represented.project) }

          #bbm(
          schema :fact_due_date,
                 type: 'Date',
                 required: false,
                 show_if: ->(*) { !represented.milestone? }
          # schema :first_due_date,
          #        type: 'Date',
          #        required: false,
          #        show_if: ->(*) { !represented.milestone? }
          # schema :last_due_date,
          #        type: 'Date',
          #        required: false,
          #        show_if: ->(*) { !represented.milestone? }
          # schema :first_start_date,
          #        type: 'Date',
          #        required: false,
          #        show_if: ->(*) { !represented.milestone? }
          # schema :last_start_date,
          #        type: 'Date',
          #        required: false,
          #        show_if: ->(*) { !represented.milestone? }
          # )

          schema :date,
                 type: 'Date',
                 required: false,
                 show_if: ->(*) { represented.milestone? }

          schema :estimated_time,
                 type: 'Duration',
                 required: false,
                 writable: ->(*) { current_user_allowed_to(:edit_estimated_time, context: represented.project) }

          schema :spent_time,
                 type: 'Duration',
                 required: false,
                 show_if: ->(*) { represented.project && represented.project.module_enabled?('time_tracking') }

          schema :remaining_time,
                 type: 'Duration',
                 required: false,
                 writable: ->(*) { current_user_allowed_to(:edit_remaining_time, context: represented.project) }

          schema :percentage_done,
                 type: 'Integer',
                 name_source: :done_ratio,
                 show_if: ->(*) { Setting.work_package_done_ratio != 'disabled' },
                 required: false,
                 writable: ->(*) { current_user_allowed_to(:edit_done_ration, context: represented.project) }

          schema :created_at,
                 type: 'DateTime'

          schema :updated_at,
                 type: 'DateTime'

          schema :author,
                 type: 'User',
                 writable: false

          schema :required_doc_type,
                 type: 'AttachType',
                 writable: ->(*) { current_user_allowed_to(:edit_required_doc_type, context: represented.project) }

          schema_with_allowed_link :project,
                                   type: 'Project',
                                   required: true,
                                   href_callback: ->(*) {
                                     if @action == :create
                                       api_v3_paths.available_projects_on_create
                                     else
                                       api_v3_paths.available_projects_on_edit(represented.id)
                                     end
                                   }

          # TODO:
          # * create an available_work_package_parent resource
          # * turn :parent into a schema_with_allowed_link

          schema :parent,
                 type: 'WorkPackage',
                 required: false,
                 writable: true

          schema_with_allowed_link :assignee,
                                   type: 'User',
                                   required: false,
                                   href_callback: ->(*) {
                                     if represented.project
                                       api_v3_paths.available_assignees(represented.project_id)
                                     end
                                   },
                                   writable: ->(*) { current_user_allowed_to(:edit_assignee, context: represented.project) }

          schema_with_allowed_link :responsible,
                                   type: 'User',
                                   required: false,
                                   href_callback: ->(*) {
                                     if represented.project
                                       api_v3_paths.available_responsibles(represented.project_id)
                                     end
                                   },
                                   writable: ->(*) { current_user_allowed_to(:edit_responsible, context: represented.project) }

          schema_with_allowed_collection :type,
                                         value_representer: Types::TypeRepresenter,
                                         link_factory: ->(type) {
                                           {
                                             href: api_v3_paths.type(type.id),
                                             title: type.name
                                           }
                                         },
                                         has_default: false,
                                         writable: ->(*) { current_user_allowed_to(:edit_type, context: represented.project) }

          schema_with_allowed_collection :status,
                                         value_representer: Statuses::StatusRepresenter,
                                         link_factory: ->(status) {
                                           {
                                             href: api_v3_paths.status(status.id),
                                             title: status.name
                                           }
                                         },
                                         has_default: true

          schema_with_allowed_collection :category,
                                         value_representer: Categories::CategoryRepresenter,
                                         link_factory: ->(category) {
                                           {
                                             href: api_v3_paths.category(category.id),
                                             title: category.name
                                           }
                                         },
                                         required: false,
                                         writable: ->(*) { current_user_allowed_to(:edit_category, context: represented.project) }

          #zbd(
          schema_with_allowed_collection :contract,
                                         value_representer: Contracts::ContractRepresenter,
                                         link_factory: ->(contract) {
                                           {
                                             href: api_v3_paths.contract(contract.id),
                                             title: contract.contract_subject
                                           }
                                         },
                                         required: false,
                                         writable: ->(*) { current_user_allowed_to(:edit_contract, context: represented.project) }

          schema_with_allowed_collection :required_doc_type,
                                         value_representer: AttachTypes::AttachTypeRepresenter,
                                         link_factory: ->(required_doc_type) {
                                           {
                                             href: api_v3_paths.attach_type(required_doc_type.id),
                                             title: required_doc_type.name
                                           }
                                         },
                                         required: false,
                                         writable: ->(*) { current_user_allowed_to(:edit_required_doc_type, context: represented.project) }
          #)

          schema_with_allowed_collection :version,
                                         value_representer: Versions::VersionRepresenter,
                                         link_factory: ->(version) {
                                           {
                                             href: api_v3_paths.version(version.id),
                                             title: version.name
                                           }
                                         },
                                         required: false,
                                         writable: ->(*) { current_user_allowed_to(:edit_fixed_version, context: represented.project) }

          #xcc(
          schema_with_allowed_collection :organization,
                                         value_representer: Organizations::OrganizationRepresenter,
                                         link_factory: ->(organization) {
                                           {
                                             href: api_v3_paths.organization(organization.id),
                                             title: organization.name
                                           }
                                         },
                                         required: false,
                                         writable: ->(*) { current_user_allowed_to(:edit_organization, context: represented.project) }

          schema_with_allowed_collection :arbitary_object,
                                         value_representer: ArbitaryObjects::ArbitaryObjectRepresenter,
                                         link_factory: ->(arbitary_object) {
                                           {
                                             href: api_v3_paths.arbitary_object(arbitary_object.id),
                                             title: arbitary_object.name
                                           }
                                         },
                                         required: false,
                                         writable: ->(*) { current_user_allowed_to(:edit_arbitary_object, context: represented.project) }

          # )
          #+tan
          schema_with_allowed_collection :raion,
                                         value_representer: Raions::RaionRepresenter,
                                         link_factory: ->(raion) {
                                           {
                                             href: api_v3_paths.raion(raion.id),
                                             title: raion.name
                                           }
                                         },
                                         required: false,
                                         writable: ->(*) { current_user_allowed_to(:edit_raion, context: represented.project) }
          #-tan
          # knm+
          schema_with_allowed_collection :period,
                                         value_representer: Periods::PeriodRepresenter,
                                         link_factory: ->(period) {
                                           {
                                             href: api_v3_paths.period(period.id),
                                             title: period.name
                                           }
                                         },
                                         required: false,
                                         writable: ->(*) { current_user_allowed_to(:edit_period, context: represented.project) }

          schema_with_allowed_collection :control_level,
                                         value_representer: ControlLevels::ControlLevelRepresenter,
                                         link_factory: ->(control_level) {
                                           {
                                             href: api_v3_paths.control_level(control_level.id),
                                             title: control_level.name
                                           }
                                         },
                                         required: false,
                                         writable: ->(*) { current_user_allowed_to(:edit_control_level, context: represented.project) }

          schema :indication,
                 type: 'String'
          # knm-
          schema_with_allowed_collection :priority,
                                         value_representer: Priorities::PriorityRepresenter,
                                         link_factory: ->(priority) {
                                           {
                                             href: api_v3_paths.priority(priority.id),
                                             title: priority.name
                                           }
                                         },
                                         required: false,
                                         has_default: true,
                                         writable: ->(*) { current_user_allowed_to(:edit_priority, context: represented.project) }

          def attribute_groups
            (represented.type && represented.type.attribute_groups || []).map do |group|
              if group.is_a?(Type::QueryGroup)
                ::API::V3::WorkPackages::Schema::FormConfigurations::QueryRepresenter
                  .new(group, current_user: current_user, embed_links: true)
              else
                ::API::V3::WorkPackages::Schema::FormConfigurations::AttributeRepresenter
                  .new(group, current_user: current_user, project: represented.project, embed_links: true)
              end
            end
          end

          ##
          # Return a map of attribute => group name
          def attribute_group_map(key)
            return nil if represented.type.nil?
            @attribute_group_map ||= begin
              represented.type.attribute_groups.each_with_object({}) do |group, hash|
                Array(group.active_members(represented.project)).each { |prop| hash[prop] = group.translated_key }
              end
            end

            @attribute_group_map[key]
          end

          private

          def custom_field_cache_key
            custom_fields = represented.available_custom_fields
            OpenProject::Cache::CacheKey.expand(custom_fields)
          end

          def project_type_cache_key
            project_cache_key = represented.project ? represented.project.id : nil
            type_cache_key = represented.type ? represented.type.id : nil

            "#{project_cache_key}-#{type_cache_key}"
          end

          def type_cache_key
            represented.type.try(:updated_at)
          end

          def project_cache_key
            represented.project.updated_on
          end

          def no_caching?
            represented.no_caching?
          end
        end
      end
    end
  end
end
