class NationalProjectsController < ApplicationController
  helper :sort
  layout 'admin'

  before_action :find_national_project, only: [:edit, :update, :destroy]
  before_action :authorize_global, only: [:index, :edit, :update, :destroy, :new]
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
    if params[:tab].blank?
      redirect_to tab: :properties
    else
      @national_project = NationalProject
                      .find(params[:id])
      @tab = params[:tab]
    end
  end

  def update
    if @national_project.update_attributes(permitted_params.national_projects)
      flash[:notice] = l(:notice_successful_update)
      redirect_to national_projects_path()
    else
      render action: 'edit'
    end
  end

  def new
    @national_project = HeadPerformanceIndicatorValue.new
  end

  def destroy
    if @national_project.type === "National"
      del=0
      @national_projects.each do |national_project|
        if national_project.parent_id === @national_project.id
          # national_project.parent_id = null
          # del=del+1
          national_project.destroy
        end
      end
      # if del==0
      #   @national_project.destroy
      # else
      #   flash.now[:error] = l('notice_project_not_deleted')
      #   render action: 'index'
      # end
    else
    @national_project.destroy
    redirect_to action: 'index'
    end
    nil
  end

  def find_national_project
    @national_project = NationalProject.find(params[:id])
  end

end
