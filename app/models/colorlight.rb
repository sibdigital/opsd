require 'rubyXL'
require 'rubyXL/convenience_methods/cell'
require 'rubyXL/convenience_methods/color'
require 'rubyXL/convenience_methods/font'
require 'rubyXL/convenience_methods/workbook'
require 'rubyXL/convenience_methods/worksheet'

class Colorlight
  def self.create_xlsx(type, project = nil)
    @items = project ? get_project_work_packages(type, project) : get_work_packages(type)
    template_path = File.absolute_path('.') + '/app/reports/templates/blank.xlsx'
    @workbook = RubyXL::Parser.parse(template_path)
    @colorlight_percentage = Setting.colorlight_percentage
    @colorlight_colors = Color.colorlight_colors

    write_xlsx

    dir_path = File.absolute_path('.') + '/public/reports'
    unless File.directory?(dir_path)
      Dir.mkdir dir_path
    end
    @ready = dir_path + '/Cветофор_' + ArbitaryObjectType.find(type).name + '.xlsx'
    @workbook.write(@ready)
    @ready
  end

  # object_type_id from arbitary_objects.types
  def self.get_work_packages(object_type_id)
    sql_command = <<-SQL
      with
      arb_objects as (
        select ao.*, e.name as type_name
        from arbitary_objects as ao
        inner join enumerations as e on ao.type_id = e.id
        where type_id = :object_type_id
      ),
      work_pack as(
        select wp.*, ao.name as ao_name, ao.type_name as ao_type_name
        from work_packages as wp
        inner join arb_objects as ao on wp.arbitary_object_id = ao.id
      )
      select wp.id, wp.subject, wp.contract_id, wp.raion_id, wp.project_id, wp.ao_name, wp.ao_type_name,
             c.eis_href, c.contract_num, c.contract_date, c.date_begin, c.date_end, c.executor,
             r.name as raion_name, r.code as raion_code, r.sort_code,
             p.name as project_name
      from work_pack as wp
      left join contracts as c on wp.contract_id = c.id
      left join raions as r on wp.raion_id = r.id
      left join projects as p on wp.project_id = p.id
      order by project_name, sort_code
    SQL
    result = ActiveRecord::Base.connection.execute(ActiveRecord::Base.sanitize_sql([sql_command, object_type_id: object_type_id]))
    result.to_a
  end
  def self.get_project_work_packages(object_type_id, project)
    sql_command = <<-SQL
      with
            arb_objects as (
                select ao.*, e.name as type_name
                from arbitary_objects as ao
                         inner join enumerations as e on ao.type_id = e.id
                where type_id = :object_type_id
            ),
            work_pack as(
                select wp.*, ao.name as ao_name, ao.type_name as ao_type_name
                from (select * 
                        from work_packages as w 
                        where w.project_id = :project_id
                    ) as wp
                    inner join arb_objects as ao on wp.arbitary_object_id = ao.id
            )
        select wp.id, wp.subject, wp.contract_id, wp.raion_id, wp.project_id, wp.ao_name, wp.ao_type_name,
               c.eis_href, c.contract_num, c.contract_date, c.date_begin, c.date_end, c.executor,
               r.name as raion_name, r.code as raion_code, r.sort_code,
               p.name as project_name
        from work_pack as wp
                 left join contracts as c on wp.contract_id = c.id
                 left join raions as r on wp.raion_id = r.id
                 left join projects as p on wp.project_id = p.id
        order by project_name, sort_code
    SQL
    result = ActiveRecord::Base.connection.execute(ActiveRecord::Base.sanitize_sql([sql_command,
                                                                                    object_type_id: object_type_id,
                                                                                    project_id: project.id]))
    result.to_a
  end

  def self.cell_style(sheet, x, y, ratio)
    sheet[x][y].change_text_wrap(true)
    sheet[x][y].change_border(:top, 'thin')
    sheet[x][y].change_border(:bottom, 'thin')
    sheet[x][y].change_border(:left, 'thin')
    sheet[x][y].change_border(:right, 'thin')
    sheet[x][y].change_fill(if ratio > @colorlight_percentage[0].to_i
                              @colorlight_colors[:top][1..-1]
                            else
                              (
                              if ratio >= @colorlight_percentage[1].to_i
                                @colorlight_colors[:mid][1..-1]
                              else
                                @colorlight_colors[:low][1..-1]
                              end)
                            end)
  end

  def self.write_xlsx
    sheet = @workbook['Список']
    start_row = 5
    @items.each_with_index do |item, index|
      wp = WorkPackage.find(item["id"])
      sheet.insert_cell(start_row + index, 0, index + 1)
      sheet.insert_cell(start_row + index, 1, item["project_name"])
      sheet.insert_cell(start_row + index, 2, item["ao_name"] + ' - ' + item["subject"])
      if item["eis_href"]
        sheet.add_cell(start_row + index, 3, '', %{HYPERLINK("} + item["eis_href"] + %{","} + item["contract_num"] + %{")})
        sheet[start_row + index][3].change_font_color('0000ff')
        sheet[start_row + index][3].datatype = RubyXL::DataType::RAW_STRING
      else
        sheet.add_cell(start_row + index, 3, item["contract_num"])
      end
      sheet.insert_cell(start_row + index, 4, item["contract_date"] ? Date.parse(item["contract_date"]).strftime("%d.%m.%Y") : '')
      sheet.insert_cell(start_row + index, 5, item["date_end"] ? Date.parse(item["date_end"]).strftime("%d.%m.%Y") : '')
      sheet.insert_cell(start_row + index, 6, item["executor"])
      if wp.cost_object
        sheet.insert_cell(start_row + index, 7, ActiveSupport::NumberHelper.number_to_currency(
            wp.cost_object.material_budget_items.sum(:budget).to_f,
            delimiter: ' ',
            separator: ',',
            precision: 2
        ))
        sheet.insert_cell(start_row + index, 8, ActiveSupport::NumberHelper.number_to_currency(
            wp.cost_object.material_budget_items
                .where(cost_type_id: CostType.find_by(name: 'Федеральный бюджет'))
                .sum(:budget).to_f,
            delimiter: ' ',
            separator: ',',
            precision: 2
        ))
        sheet.insert_cell(start_row + index, 9, ActiveSupport::NumberHelper.number_to_currency(
            wp.cost_object.material_budget_items
                .where(cost_type_id: CostType.find_by(name: 'Региональный бюджет'))
                .sum(:budget).to_f,
            delimiter: ' ',
            separator: ',',
            precision: 2
        ))
      else
        sheet.insert_cell(start_row + index, 7, '')
        sheet.insert_cell(start_row + index, 8, '')
        sheet.insert_cell(start_row + index, 9, '')
      end
      if wp.cost_entries
        sheet.insert_cell(start_row + index, 10, ActiveSupport::NumberHelper.number_to_currency(
            wp.cost_entries.sum(:costs).to_f,
            delimiter: ' ',
            separator: ',',
            precision: 2
        ))
        sheet.insert_cell(start_row + index, 11, ActiveSupport::NumberHelper.number_to_currency(
            wp.cost_entries
                .where(cost_type_id: CostType.find_by(name: 'Федеральный бюджет'))
                .sum(:costs).to_f,
            delimiter: ' ',
            separator: ',',
            precision: 2
        ))
        sheet.insert_cell(start_row + index, 12, ActiveSupport::NumberHelper.number_to_currency(
            wp.cost_entries
                .where(cost_type_id: CostType.find_by(name: 'Региональный бюджет'))
                .sum(:costs).to_f,
            delimiter: ' ',
            separator: ',',
            precision: 2
        ))
      else
        sheet.insert_cell(start_row + index, 10, '')
        sheet.insert_cell(start_row + index, 11, '')
        sheet.insert_cell(start_row + index, 12, '')
      end
      risks = []
      if wp.work_package_problems.count.positive?
        wp.work_package_problems.each do |p|
          risks.push(p.description)
        end
      end
      sheet.insert_cell(start_row + index, 13, risks.join(', '))
      sheet.insert_cell(start_row + index, 14, item["raion_name"])
      sheet.insert_cell(start_row + index, 15, (wp.done_ratio.to_s || '0') + '%')
      sheet.change_row_font_size(start_row + index, 12)
      16.times do |j|
        cell_style(sheet, start_row + index, j, wp.done_ratio.to_i)
      end
    end
    # code here
  end
end
