require 'rubyXL'
require 'rubyXL/convenience_methods/cell'
require 'rubyXL/convenience_methods/color'
require 'rubyXL/convenience_methods/font'
require 'rubyXL/convenience_methods/workbook'
require 'rubyXL/convenience_methods/worksheet'

class Colorlight
  def self.create_xlsx(type, project = nil)
    @items = project ? get_project_work_packages(type, project) : get_work_packages(type)
    template_path = File.absolute_path('.') + '/app/reports/templates/colorlight_blank.xlsx'
    @workbook = RubyXL::Parser.parse(template_path)
    @colorlight_percentage = Setting.colorlight_percentage
    @colorlight_colors = Color.colorlight_colors

    write_xlsx

    dir_path = File.absolute_path('.') + '/public/reports'
    unless File.directory?(dir_path)
      Dir.mkdir dir_path
    end
    @ready = "#{dir_path}/Cветофор_#{ArbitaryObjectType.find(type).name}_#{DateTime.now.strftime("%d.%m.%Y %H:%M")}.xlsx"
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
             c.eis_href, c.contract_num, c.schedule_date, c.auction_date, c.contract_date, c.date_begin, c.date_end, c.executor,
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
               c.eis_href, c.contract_num, c.schedule_date, c.auction_date, c.contract_date, c.date_begin, c.date_end, c.executor,
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
    start_row = 2
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
      sheet.insert_cell(start_row + index, 4, item["schedule_date"] ? Date.parse(item["schedule_date"]).strftime("%d.%m.%Y") : '')
      sheet.insert_cell(start_row + index, 5, item["auction_date"] ? Date.parse(item["auction_date"]).strftime("%d.%m.%Y") : '')
      sheet.insert_cell(start_row + index, 6, item["contract_date"] ? Date.parse(item["contract_date"]).strftime("%d.%m.%Y") : '')
      sheet.insert_cell(start_row + index, 7, item["date_end"] ? Date.parse(item["date_end"]).strftime("%d.%m.%Y") : '')
      sheet.insert_cell(start_row + index, 8, item["executor"])
      if wp.cost_object
        all_costs = 0
        fed_costs = 0
        reg_costs = 0
        wp.cost_object.material_budget_items.each do |i|
          all_costs += i.costs
          fed_costs += i.costs if i.cost_type === CostType.find_by(name: 'Федеральный бюджет')
          reg_costs += i.costs if i.cost_type === CostType.find_by(name: 'Региональный бюджет')
        end
        sheet.insert_cell(start_row + index, 9, ActiveSupport::NumberHelper.number_to_currency(
            all_costs.to_f,
            delimiter: ' ',
            separator: ',',
            precision: 2
        ))
        sheet.insert_cell(start_row + index, 10, ActiveSupport::NumberHelper.number_to_currency(
            fed_costs.to_f,
            delimiter: ' ',
            separator: ',',
            precision: 2
        ))
        sheet.insert_cell(start_row + index, 11, ActiveSupport::NumberHelper.number_to_currency(
            reg_costs.to_f,
            delimiter: ' ',
            separator: ',',
            precision: 2
        ))
      else
        sheet.insert_cell(start_row + index, 9, '')
        sheet.insert_cell(start_row + index, 10, '')
        sheet.insert_cell(start_row + index, 11, '')
      end
      if wp.cost_entries
        costs_sum = wp.cost_entries.map { |cost| cost.overridden_costs || cost.costs }
        cost_fed = wp.cost_entries.where(cost_type_id: CostType.find_by(name: 'Федеральный бюджет')).map { |cost| cost.overridden_costs || cost.costs }
        cost_reg = wp.cost_entries.where(cost_type_id: CostType.find_by(name: 'Региональный бюджет')).map { |cost| cost.overridden_costs || cost.costs }
        sheet.insert_cell(start_row + index, 12, ActiveSupport::NumberHelper.number_to_currency(
            costs_sum.sum.to_f,
            delimiter: ' ',
            separator: ',',
            precision: 2
        ))
        sheet.insert_cell(start_row + index, 13, ActiveSupport::NumberHelper.number_to_currency(
            cost_fed.sum.to_f,
            delimiter: ' ',
            separator: ',',
            precision: 2
        ))
        sheet.insert_cell(start_row + index, 14, ActiveSupport::NumberHelper.number_to_currency(
            cost_reg.sum.to_f,
            delimiter: ' ',
            separator: ',',
            precision: 2
        ))
      else
        sheet.insert_cell(start_row + index, 12, '')
        sheet.insert_cell(start_row + index, 13, '')
        sheet.insert_cell(start_row + index, 14, '')
      end
      risks = []
      if wp.work_package_problems.count.positive?
        wp.work_package_problems.each do |p|
          risks.push(p.description)
        end
      end
      sheet.insert_cell(start_row + index, 15, risks.join(', '))
      sheet.insert_cell(start_row + index, 16, item["raion_name"])
      sheet.insert_cell(start_row + index, 17, (wp.done_ratio.to_s || '0') + '%')
      if !wp.attachments.count.zero?
        file_str = ''
        wp.attachments.map do |a|
          file_str += "#{Setting.host_name}/attachments/#{a.id}/#{a.filename}\n"
        end
        sheet.insert_cell(start_row + index, 18, file_str)
      else
        sheet.insert_cell(start_row + index, 18, '')
      end
      sheet.change_row_font_size(start_row + index, 12)
      19.times do |j|
        cell_style(sheet, start_row + index, j, wp.done_ratio.to_i)
      end
    end
    # code here
  end
end
