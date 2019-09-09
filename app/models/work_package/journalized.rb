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

module WorkPackage::Journalized
  extend ActiveSupport::Concern

  included do
    acts_as_journalized calculate: -> { { parent_id: parent && parent.id } }

    # This one is here only to ease reading
    module JournalizedProcs
      def self.event_title
        Proc.new do |o|
          title = o.to_s
          title << " (#{o.status.name})" if o.status.present?

          title
        end
      end

      def self.event_name
        Proc.new do |o|
          I18n.t(o.event_type.underscore, scope: 'events')
        end
      end

      def self.event_type
        Proc.new do |o|
          journal = o.last_journal
          t = 'work_package'

          t << if journal && journal.details.empty? && !journal.initial?
                 '-note'
               else
                 status = Status.find_by(id: o.status_id)

                 status.try(:is_closed?) ? '-closed' : '-edit'
               end
          t
        end
      end

      def self.event_url
        Proc.new do |o|
          { controller: :work_packages, action: :show, id: o.id }
        end
      end
    end

    acts_as_event title: JournalizedProcs.event_title,
                  type: JournalizedProcs.event_type,
                  name: JournalizedProcs.event_name,
                  url: JournalizedProcs.event_url
    #knm
    # Ниже происходит привязка полей таблицы к различным форматтерам
    register_on_journal_formatter :id, :parent_id
    # :fraction - число с плавающей запятой
    register_on_journal_formatter :fraction, :estimated_hours, :remaining_hours
    #  :decimal - целые числа
    register_on_journal_formatter :decimal, :done_ratio
    # diff - создает ссылку при переходе по которой отображает разницу в данных
    register_on_journal_formatter :diff, :description
    register_on_journal_formatter :attachment, /attachments_?\d+/
    register_on_journal_formatter :custom_field, /custom_fields_\d+/

    # :named_association - для колонок со ссылками на другие объекты
    register_on_journal_formatter :named_association, :parent_id, :project_id,
                                  :status_id, :type_id,
                                  :assigned_to_id, :priority_id,
                                  :category_id, :fixed_version_id,
                                  :planning_element_status_id,
                                  :author_id, :responsible_id,
                                  # knm +
                                  :raion_id, :organization_id,
                                  :arbitary_object_id, :cost_object_id,
                                  :required_doc_type_id,
                                  # -
                                  #zbd(
                                  :contract_id, :target_id, :required_doc_type_id, :organization_id
                                  #)

    # :datetime - формат даты
    register_on_journal_formatter :datetime, :start_date, :due_date,
                                  # knm +
                                  :fact_due_date
                                  # -
    # :plaintext - неформатированный текст
    register_on_journal_formatter :plaintext, :subject,
                                  #knm +
                                  :story_points, :sed_href,
                                  :result_agreed, :plan_num_pp
                                  # -
    #  :hidden - для скрытых колонок
    register_on_journal_formatter :hidden, :updated_at, :first_start_date,
                                  :last_start_date, :first_due_date, :last_due_date
  end
end
