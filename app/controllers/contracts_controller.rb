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
                    'contract_subject' => "#{Contract.table_name}.contract_subject",
                    'contract_date' => "#{Contract.table_name}.contract_date",
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
end
