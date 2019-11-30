#-- encoding: UTF-8
#-- copyright
# OpenProject Documents Plugin
#
# Former OpenProject Core functionality extracted into a plugin.
#
# Copyright (C) 2009-2014 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

class DocumentsController < ApplicationController
  include CustomFilesHelper
  include CounterHelper
  include ClassifierHelper
  default_search_scope :documents
  model_object Document
  before_action :find_project_by_project_id, only: [:index, :new, :create]
  before_action :find_model_object, except: [:index, :new, :create]
  before_action :find_project_from_association, except: [:index, :new, :create]
  before_action :authorize
  # helper :sort
  include SortHelper
  include CustomFieldsHelper
  include PaginationHelper

  before_action only: [:create, :update] do
    upload_custom_file("document", "Document")
  end

  after_action only: [:create, :update] do
    assign_custom_file_name("Document", @document.id)
    parse_classifier_value("Document", @document.class.name, @document.id)
  end

  after_action only: [:create] do
    init_counter_value("Document", @document.class.name, @document.id)
  end

  def index
    sort_init 'id', 'asc'
    sort_columns = {'id' => "#{Document.table_name}.id",
                    'title' => "#{Document.table_name}.title",
                    'created_on' => "#{Document.table_name}.created_on",
                    'user' => "#{Document.table_name}.user_id"}

    sort_update sort_columns

    if params[:commit] == "Применить"
      params[:filter_start_date].blank? ? @filter_start_date = "" : @filter_start_date = params[:filter_start_date]
      params[:filter_end_date].blank? ? @filter_end_date = "" : @filter_end_date = params[:filter_end_date]
      params[:filter_user].blank? ? @filter_user = "" : @filter_user = params[:filter_user]
      params[:filter_category].blank? ? @filter_category = "" : @filter_category = params[:filter_category]
    end
    if params[:selected_view].blank?
      @selected_view = "table"
    else
      @selected_view = params[:selected_view]
    end
    @documents = Document.where("project_id = ?", @project.id)
    @existing_users = @documents.select(:user_id).distinct.map {|u| [User.find(u.user_id).fio, u.user_id]}
    @existing_categories = @documents.select(:category_id).distinct.map {|c| [c.category.name, c.category_id]}
    unless @filter_end_date.blank?
      end_of_day = (@filter_end_date.to_date + 1.days).to_s
      @documents = @documents.where('created_on between ? and ?', "1000-01-01", end_of_day)
    end
    unless @filter_start_date.blank?
      @documents = @documents.where('created_on between ? and ?', @filter_start_date, "3000-01-01")
    end
    unless @filter_user.blank?
      @documents = @documents.where('user_id = ?', @filter_user)
    end
    unless @filter_category.blank?
      @documents = @documents.where('category_id = ?', @filter_category)
    end
    @documents = @documents.order(sort_clause)
  end

  def show
    @attachments = @document.attachments.order(Arel.sql('created_at DESC'))
  end

  def new
    # unless params["wpId"].blank?
    #
    # end

    @wp = params["wpId"]
    @document = @project.documents.build
    @document.attributes = document_params
  end

  def create
    @document = @project.documents.build
    @document.attributes = document_params
    @document.attach_files(permitted_params.attachments.to_h)
    @document.update_attribute(:user_id, User.current.id)

    if @document.save
      render_attachment_warning_if_needed(@document)
      Alert.create_pop_up_alert(@document, "Created", User.current, User.current)
      flash[:notice] = l(:notice_successful_create)
      redirect_to project_documents_path(@project)
    else
      render action: 'new'
    end
  end

  def edit
    @categories = DocumentCategory.all
  end

  def update
    @document.attributes = document_params
    @document.attach_files(permitted_params.attachments.to_h)

    if @document.save
      render_attachment_warning_if_needed(@document)
      flash[:notice] = l(:notice_successful_update)
      redirect_to action: 'show', id: @document
    else
      render action: 'edit'
    end
  end

  def destroy
    @document.destroy
    redirect_to controller: '/documents', action: 'index', project_id: @project
  end

  def add_attachment
    @document.attach_files(permitted_params.attachments.to_h)
    attachments = @document.attachments.select(&:new_record?)

    @document.save
    render_attachment_warning_if_needed(@document)

    saved_attachments = attachments.select(&:persisted?)
    if saved_attachments.present? && Setting.notified_events.include?('document_added')
      users = saved_attachments.first.container.recipients
      users.each do |user|
        UserMailer.attachments_added(user, saved_attachments).deliver

      end
    end
    redirect_to action: 'show', id: @document
  end

  private

  def document_params
    document_params = params.fetch(:document, {}).permit('category_id', 'title', 'work_package_id', 'description', 'document')
    document_params = document_params.merge(custom_field_values(:document))
  end

  def custom_field_values(key, required: true)
    # a hash of arbitrary values is not supported by strong params
    # thus we do it by hand
    object = params.fetch(key, {})
    values = object[:custom_field_values] || ActionController::Parameters.new

    # only permit values following the schema
    # 'id as string' => 'value as string'
    values.reject! {|k, v| k.to_i < 1 || !v.is_a?(String)}

    values.empty? ? {} : {'custom_field_values' => values.permit!}
  end
end
