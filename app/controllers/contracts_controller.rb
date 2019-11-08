# by zbd
# 22.06.2019

class ContractsController < ApplicationController
  before_action :require_project_admin
  before_action :find_contracts, only: [:edit, :update, :destroy]
  before_action :find_project
  before_action :find_project_id, only: [:new, :create, :edit, :update]

  helper :sort
  include SortHelper
  include PaginationHelper
  include ::IconsHelper
  include ::ColorsHelper
  include CustomFilesHelper
  include CounterHelper
  include ClassifierHelper

  before_action only: [:create, :update] do
    upload_custom_file("contract", "ContractCustomField")
  end

  after_action only: [:create, :update] do
    assign_custom_file_name("Contract", @contract.id)
    parse_classifier_value("Contract", @contract.class.name, @contract.id)
    init_counter_value("Contract", @contract.class.name, @contract.id)
  end

  def index
    sort_columns = {'id' => "#{Contract.table_name}.id",
                    'contract_date' => "#{Contract.table_name}.contract_date",
                    'contract_num' => "#{Contract.table_name}.contract_num",
                    'contract_subject' => "#{Contract.table_name}.contract_subject",
                    'eis_href' => "#{Contract.table_name}.eis_href",
                    'price' => "#{Contract.table_name}.price",
                    'executor' => "#{Contract.table_name}.executor"
    }
    sort_init 'id', 'desc'
    sort_update sort_columns

    @contracts = Contract
                     .order(sort_clause)
                     .page(page_param)
                     .per_page(per_page_param)
  end

  def edit
    @contract = Contract.find(params[:id])
  end

  def new
    @contract = Contract.new
  end

  def create
   @contract = Contract.new(permitted_params.contract)
    if @contract.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to action: 'index'
    else
      render action: 'new'
    end
  end

  def update
    if @contract.update_attributes(permitted_params.contract)
      flash[:notice] = l(:notice_successful_update)
      redirect_to project_contracts_path
    else
      render action: 'edit'
    end
  end

  def destroy
    @contract.destroy
    redirect_to action: 'index'
    return
  end

  protected

  def default_breadcrumb
    if action_name == 'index'
      t(:label_contracts)
    else
      ActionController::Base.helpers.link_to(t(:label_contracts), project_contracts_path)
    end
  end

  def show_local_breadcrumb
    true
  end

  def find_contracts
    @contract = Contract.find(params[:id])
  end

  def find_project
    @project = Project.find(params[:project_id])
  end

  def find_project_id
    data = Project.where(:identifier => params[:project_id]).pluck(:id)
    @project_id = data[0]
  end

end
