#-- encoding: UTF-8
#-- copyright
# OpenProject is a project management system.
# Copyright (C) 2012-2015 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
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
# See doc/COPYRIGHT.rdoc for more details.
module BasicData
  class RisksCustomFieldsSeeder < Seeder
    def seed_data!
      CustomField.transaction do
        print '    ↳ Creating custom fields...'
        create_cf_tr!
        create_cf_pr!
      end

      puts
    end

    def create_cf_tr!
      # create some custom fields and add them to the project
      CustomField.create!(name: 'Предлагаемые решения',
                          type: 'TypedRiskCustomField',
                          is_required: false,
                          field_format: 'text')
      print '.'
      trl = CustomField.create!(name: 'Раздел проекта',
                                type: 'TypedRiskCustomField',
                                is_required: false,
                                possible_values: ['Основные положения',
                                                  'Цели и показатели',
                                                  'Результаты',
                                                  'Финансовое обеспечение',
                                                  'Участники проекта',
                                                  'Дополнительная информация',
                                                  'План мероприятий',
                                                  'Методика расчета дополнительных показателей регионального проекта'],
                                field_format: 'list')
      print '.'
    end

    def create_cf_pr!
      CustomField.create!(name: 'Предлагаемые решения',
                          type: 'ProjectRiskCustomField',
                          is_required: false,
                          field_format: 'text')
      print '.'
      prl = CustomField.create!(name: 'Раздел проекта',
                                type: 'ProjectRiskCustomField',
                                is_required: false,
                                possible_values: ['Основные положения',
                                                  'Цели и показатели',
                                                  'Результаты',
                                                  'Финансовое обеспечение',
                                                  'Участники проекта',
                                                  'Дополнительная информация',
                                                  'План мероприятий',
                                                  'Методика расчета дополнительных показателей регионального проекта'],
                                field_format: 'list')
      print '.'
    end
  end
end
