require 'rubyXL'
require 'rubyXL/convenience_methods/cell'
require 'rubyXL/convenience_methods/color'
require 'rubyXL/convenience_methods/font'
require 'rubyXL/convenience_methods/workbook'
require 'rubyXL/convenience_methods/worksheet'
class ReportProjectController < ApplicationController

  include Downloadable

  def index
    generate_svod_otchet
    send_to_user filepath: @project_svod_otchet_report_path
  end

  def generate_svod_otchet
    template_path = File.absolute_path('.') +'/'+'app/reports/templates/project_svod_otchet_report.xlsx'
    @workbook = RubyXL::Parser.parse(template_path)
    #@workbook.calc_pr.full_calc_on_load = true

    generate_key_risk_sheet

    dir_path = File.absolute_path('.') + '/public/reports'
    if  !File.directory?(dir_path)
      Dir.mkdir dir_path
    end

    @project_svod_otchet_report_path = dir_path + '/project_svod_otchet_report.xlsx'
    @workbook.write(@project_svod_otchet_report_path)
  end

  def generate_key_risk_sheet
    sheet = @workbook['Свод проектов']
    projects = Project.all
    data_row = 1
    projects.each_with_index do |project, i|
      sheet.insert_cell(data_row + i, 0, project.name)
      sheet.insert_cell(data_row + i, 1, project.national_project ? project.national_project.name : '')
      sheet.insert_cell(data_row + i, 2, project.federal_project ? project.federal_project.name : '')
      sheet.insert_cell(data_row + i, 3, project.rukovoditel.empty? ? '' :project.rukovoditel['fio'])
      sheet.insert_cell(data_row + i, 4, project.curator.empty? ? '' : project.curator['fio'])
      sheet.insert_cell(data_row + i, 5, project.get_project_status ? project.get_project_status.name : '')
      sheet.insert_cell(data_row + i, 6, project.get_project_approve_status ? project.get_project_approve_status.name : '')
      sheet.insert_cell(data_row + i, 7, project.get_done_ratio)
      sheet.insert_cell(data_row + i, 8, project.start_date ? project.start_date.strftime("%d.%m.%Y") : '')
      sheet.insert_cell(data_row + i, 9, project.due_date ? project.due_date.strftime("%d.%m.%Y") : '')
      sheet.insert_cell(data_row + i, 10, project.fact_start_date ? project.fact_start_date.strftime("%d.%m.%Y") : '')
      sheet.insert_cell(data_row + i, 11, project.fact_due_date ? project.fact_due_date.strftime("%d.%m.%Y") : '')

      12.times do |j|
        sheet.sheet_data[data_row + i][j].change_border(:top, 'thin')
        sheet.sheet_data[data_row + i][j].change_border(:bottom, 'thin')
        sheet.sheet_data[data_row + i][j].change_border(:left, 'thin')
        sheet.sheet_data[data_row + i][j].change_border(:right, 'thin')
      end
    end
  end
end
