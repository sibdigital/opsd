# tmd
class CatalogLoadersController < ApplicationController

  require 'roo'
  require 'date'
  include PlanUploadersHelper

  def index
    @project_id = params[:project]
  end

  def destroy

  end

  def load
    uploaded_io = params[:file]
    catalog = params[:catalog_type]
    project = params[:project]
    filename = ''

    File.open(Rails.root.join('public', 'uploads', 'catalog_loaders', uploaded_io.original_filename), 'wb') do |file|
      filename = Rails.root.join('public', 'uploads', 'catalog_loaders', uploaded_io.original_filename)
      file.write(uploaded_io.read)
    end

    settings = PlanUploaderSetting.select('column_name, column_num, column_type, is_pk').where("table_name = ?", catalog).order('column_num ASC').all
    xlsx = Roo::Excelx.new(filename)

    error_occured = false

    xlsx.each_row_streaming(offset: params[:first_row].to_i - 1) do |row|
      attributes = {}

      for i in (0...settings.length)
        attribute = settings[i]['column_name']
        if settings[i]['column_type'] == "date"
          begin
            date = row[settings[i]['column_num'] - 1].to_s
            formatted_date = Date.strptime(date.to_s, "%d/%m/%Y")
            attributes[attribute] = formatted_date
          rescue Exception => e
            break
          end
        else
          attributes[attribute] = row[settings[i]['column_num'] - 1].to_s
        end
      end

      object = nil

      case catalog
      when "contracts"
        object = Contract.new(attributes)
      when "organizations"
        attributes['org_type'] = params[:org_type]
        object = Organization.new(attributes)
      when "users"
        object = User.new(attributes)
      when "positions"
        object = Position.new(attributes)
      when "risks"
        possibility_array = Enumeration.where(:name => attributes['possibility_id'], :type => "Possibility").pluck(:id)
        importance_array = Enumeration.where(:name => attributes['importance_id'], :type => "Importance").pluck(:id)
        attributes['possibility_id'] = possibility_array[0]
        attributes['importance_id'] = importance_array[0]
        attributes['type'] = "TypedRisk"

        object = Risk.new(attributes)
      when "arbitary_objects"
        object = ArbitaryObject.new(attributes)
      when "groups"
        attributes['type'] = "Group"
        object = Group.new(attributes)
      end

      # Возвращает true или false. Если false - вывести сообщение об ошибке
      if !object.save
        error_occured = true
      end
    end

    if error_occured
      flash[:error] = l(:notice_error_occured_while_loading)
    else
      flash[:notice] = l(:notice_successful_create)
    end

    if catalog == "positions"
      redirect_to :controller => "organizations", :action => "positions"
    elsif catalog == "organizations"
      redirect_to :controller => "organizations", :action => "index"
    elsif catalog == "risks"
      redirect_to :controller => "typed_risks", :action => "index"
    elsif catalog == "contracts"
      redirect_to project_contracts_path(project)
    else
      redirect_to :controller => catalog, :action => 'index'
    end
  end

end
