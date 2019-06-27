# by zbd
# 22.06.2019

class ContractsController < ApplicationController
  layout 'admin'

  before_action :require_admin
  before_action :find_contracts, only: [:edit, :update, :destroy]

  helper :sort
  include SortHelper
  include PaginationHelper
  include ::IconsHelper
  include ::ColorsHelper

  def index
    sort_columns = {'id' => "#{Contract.table_name}.id",
                    'contract_date' => "#{Contract.table_name}.contract_date",
                    'contract_num' => "#{Contract.table_name}.contract_num",
                    'contract_subject' => "#{Contract.table_name}.contract_subject",
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
      redirect_to contracts_path
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
      ActionController::Base.helpers.link_to(t(:label_contracts), contracts_path)
    end
  end

  def show_local_breadcrumb
    true
  end

  def find_contracts
    @contract = Contract.find(params[:id])
  end

end
