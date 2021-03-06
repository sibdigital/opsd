#-- encoding: UTF-8
# This file written by BBM
# 25/04/2019

class TypedRisksController < ApplicationController
  layout 'admin'

  before_action :require_coordinator
  before_action :find_typed_risk, only: [:edit, :update, :destroy]
  before_action only: [:create, :update] do
    upload_custom_file("typed_risk", "TypedRisk")
  end

  after_action only: [:create, :update] do
    assign_custom_file_name("Risk", @typed_risk.id)
    parse_classifier_value("Risk", @typed_risk.class.name, @typed_risk.id)
  end

  after_action only: [:create] do
    init_counter_value("Risk", @typed_risk.class.name, @typed_risk.id)
  end

  helper :sort
  include SortHelper
  include PaginationHelper
  include ::IconsHelper
  include ::ColorsHelper
  include CustomFilesHelper
  include CounterHelper
  include ClassifierHelper

  def index
    sort_columns = {'id' => "#{TypedRisk.table_name}.id",
                    'name' => "#{TypedRisk.table_name}.name",
                    'owner' => "#{TypedRisk.table_name}.owner_id",
                    'possibility' => "#{TypedRisk.table_name}.possibility_id",
                    'importance' => "#{TypedRisk.table_name}.importance_id"
    }

    sort_init 'id', 'desc'
    sort_update sort_columns

    @typed_risks = TypedRisk
                     .order(sort_clause)
                     .page(page_param)
                     .per_page(per_page_param)
  end

  def edit
    if params[:tab].blank?
      redirect_to tab: :properties
    else
      @typed_risk = TypedRisk
               .find(params[:id])
      @tab = params[:tab]
    end
  end

  def new
    @typed_risk = TypedRisk.new
  end

  def create
    @typed_risk = TypedRisk.new(permitted_params.typed_risk)

    if @typed_risk.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to action: 'index'
    else
      render action: 'new'
    end
  end

  def update
    if @typed_risk.update_attributes(permitted_params.typed_risk)
      flash[:notice] = l(:notice_successful_update)
      redirect_to typed_risks_path()
    else
      render action: 'edit'
    end
  end

  def destroy
    @typed_risk.destroy
    redirect_to action: 'index'
    return
  end

  protected

  def default_breadcrumb
    if action_name == 'index'
      t(:label_typed_risks)
    else
      ActionController::Base.helpers.link_to(t(:label_typed_risks), typed_risks_path)
    end
  end

  def show_local_breadcrumb
    true
  end

  def find_typed_risk
    @typed_risk = TypedRisk.find(params[:id])
  end
end
