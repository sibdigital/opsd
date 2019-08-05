class NationalProjectsController < ApplicationController
  helper :sort
  include SortHelper
  include PaginationHelper
  include ::IconsHelper
  include ::ColorsHelper
  include TargetsHelper
  def index
    sort_columns = {'id' => "#{NationalProject.table_name}.id",
                    'name'=>"#{NationalProject.table_name}.name",
                    'leader'=>"#{NationalProject.table_name}.leader",
                    'curator'=>"#{NationalProject.table_name}.curator",
                    'type'=>"#{NationalProject.table_name}.type",
                    'start_date'=>"#{NationalProject.table_name}.start_date",
                    'due_date'=>"#{NationalProject.table_name}.due_date"
    }
    sort_init [['parent_id', 'asc'],['id', 'asc']]
    sort_update sort_columns
    @national_projects = NationalProject.order(sort_clause).page(page_param).per_page(per_page_param)
  end

  def edit
  end

  def new
  end

  def destroy
  end
end
