#-- encoding: UTF-8
# This file written by BBM
# 26/04/2019

class ProjectRisksController < ApplicationController

  helper :sort
  include SortHelper
  include PaginationHelper
  include ::IconsHelper
  include ::ColorsHelper

  def index
    sort_columns = {'id' => "#{ProjectRisk.table_name}.id",
                    'name' => "#{ProjectRisk.table_name}.name",
                    'possibility' => "#{ProjectRisk.table_name}.possibility_id",
                    'importance' => "#{ProjectRisk.table_name}.importance_id"
    }

    sort_init 'id', 'desc'
    sort_update sort_columns

    @project_risks = ProjectRisk
                     .order(sort_clause)
                     .page(page_param)
                     .per_page(per_page_param)
  end

  def new
    @project_risk = ProjectRisk.new
  end

  def create
    @project_risk = ProjectRisk.new(permitted_params.project_risk)

    if @project_risk.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to action: 'index'
    else
      render action: 'new'
    end
  end
end
