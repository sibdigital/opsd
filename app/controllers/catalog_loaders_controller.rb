# tmd
class CatalogLoadersController < ApplicationController

  require 'roo'
  require 'date'
  include PlanUploadersHelper

  def index

  end

  # def new
  #   @catalog_loader = CatalogLoader.new
  # end

  # def create
  #   @first_row_num = params[:first_row_num]
  #
  #   if @plan_uploader.save
  #     load
  #     redirect_to project_stages_path, notice: "Данные загружены."
  #   else
  #     render "new"
  #   end
  # end

  def destroy

  end

  def load
    uploaded_io = params[:file]
    starts_from = params[:first_row].to_i
    catalog = params[:catalog_type]
    org_type = params[:org_type]
    filename = ''

    File.open(Rails.root.join('public', 'uploads', 'catalog_loaders', uploaded_io.original_filename), 'wb') do |file|
      filename = Rails.root.join('public', 'uploads', 'catalog_loaders', uploaded_io.original_filename)
      file.write(uploaded_io.read)
    end

    settings = PlanUploaderSetting.select('column_name, column_num, column_type, is_pk').where("table_name = ?", catalog).order('column_num ASC').all
    xlsx = Roo::Excelx.new(filename)

    error_occured = false

    xlsx.each_row_streaming(offset: starts_from - 1) do |row|
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
        attributes['org_type'] = org_type
        object = Organization.new(attributes)
      when "users"
        object = User.new(attributes)
      when "positions"
        object = Position.new(attributes)
      when "risks"
        object = Risk.new(attributes)
      when "arbitary_objects"
        object = ArbitaryObject.new(attributes)
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
    redirect_to :controller => catalog, :action => 'index'
  end

end
