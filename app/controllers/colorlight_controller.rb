require 'rubyXL'
require 'rubyXL/convenience_methods/cell'
require 'rubyXL/convenience_methods/color'
require 'rubyXL/convenience_methods/font'
require 'rubyXL/convenience_methods/workbook'
require 'rubyXL/convenience_methods/worksheet'

class ColorlightController < ApplicationController
  include Downloadable

  layout 'admin'
  before_action :authorize_global, only: [:index]


  def index; end

  def create
    # code here
  end

  private

  def get_work_packages(object_type_id)
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

    result = ActiveRecord::Base.connection.execute(
      sanitize_sql_for_assignment([sql_command, object_type_id: object_type_id])
    )
    result
  end
end
