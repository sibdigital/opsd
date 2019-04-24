#-- encoding: UTF-8
# This file written by BBM
# 23/04/2019
class RisksController < ApplicationController
  layout 'admin'

  before_action :require_admin
  before_action :find_risk, only: [:edit, :update, :destroy]

  def index; end

  def edit; end

  def new
    risk_class = risk_class(permitted_params.risk_type)
    if risk_class
      @risk = risk_class.new
    else
      render_400 # bad request
    end
  end

  def create
    risk_params = permitted_params.risks
    type = permitted_params.risk_type
    @risk = (risk_class(type) || Risk).new do |r|
      r.attributes = risk_params
    end

    if @risk.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to action: 'index', type: @risk.type
    else
      render action: 'new'
    end
  end

  def update
    risk_params = permitted_params.risks
    type = permitted_params.risk_type
    @risk.type = risk_class(type).try(:name) || @risk.type
    if @risk.update_attributes risk_params
      flash[:notice] = l(:notice_successful_update)
      redirect_to risks_path(type: @risk.type)
    else
      render action: 'edit'
    end
  end

  def destroy
    #if !@risk.in_use?
    # No associated objects
    @risk.destroy
    redirect_to action: 'index'
    return
    #elsif params[:reassign_to_id]
    # if reassign_to = @risk.class.find_by(id: params[:reassign_to_id])
    #  @risk.destroy(reassign_to)
    # redirect_to action: 'index'
    #return
    #end
    #end 
    #@risks = @risk.class.all - [@risk]
  end

  protected

  def default_breadcrumb
    if action_name == 'index'
      t(:label_risks)
    else
      ActionController::Base.helpers.link_to(t(:label_risks), risks_path)
    end
  end

  def show_local_breadcrumb
    true
  end

  def find_risk
    @risk = Risk.find(params[:id])
  end

  ##
  # Find a risk class with the given Name
  # this should be fail save for nonsense names or names
  # which are no risks to prevent remote code execution attacks.
  # params: type (string)
  def risk_class(type)
    klass = type.to_s.constantize
    raise NameError unless klass.ancestors.include? Risk
    klass
  rescue NameError
    nil
  end
end
