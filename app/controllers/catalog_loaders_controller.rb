# tmd
class CatalogLoadersController < ApplicationController

  require 'roo'
  require 'date'
  #require 'translit'
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
    prepare_roo
    uploaded_io = params[:file]
    starts_from = params[:first_row].to_i
    catalog = params[:catalog_type]
    filename = ''

    File.open(Rails.root.join('public', 'uploads', 'catalog_loaders', uploaded_io.original_filename), 'wb') do |file|
      filename = Rails.root.join('public', 'uploads', 'catalog_loaders', uploaded_io.original_filename)
      file.write(uploaded_io.read)
    end

    settings = PlanUploaderSetting.select('column_name, column_num, column_type, is_pk').where("table_name = ?", catalog).order('column_num ASC').all
    xlsx = Roo::Excelx.new(filename)

    xlsx.each_row_streaming(offset: starts_from - 1) do |row|
      attributes = {}
      for i in (0...settings.length)
        attribute = settings[i]['column_name']
        attributes[attribute] = row[i].to_s
      end

      case catalog
      when "contracts"
        contract = Contract.new(attributes)
        # Возвращает true или false. Если false - вывести сообщение об ошибке
        result = contract.save
      when "work_packages"
        work_package = WorkPackage.new(attributes)
        work_package.save
      end

      # flash[:notice] = l(:notice_successful_create)
    end

    redirect_to :controller => catalog, :action => 'index'
  end


  def prepare_roo
    Roo::Excelx::Cell::Number.module_eval do
      def create_numeric(number)
        return number if Roo::Excelx::ERROR_VALUES.include?(number)

        case @format
        when /%/
          Float(number)
        when /\.0/
          Float(number)
        else
          number.include?('.') || (/\A[-+]?\d+E[-+]?\d+\z/i =~ number) ? Float(number) : number.to_s.to_i
        end
      end
    end
  end


  private

  def new_member(user_id)
    Member.new(permitted_params.member).tap do |member|
      member.user_id = user_id if user_id
    end
  end

end
