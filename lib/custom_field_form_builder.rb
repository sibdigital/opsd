#-- encoding: UTF-8
#-- copyright
# OpenProject is a project management system.
# Copyright (C) 2012-2018 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2017 Jean-Philippe Lang
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
# See docs/COPYRIGHT.rdoc for more details.
#++

require 'action_view/helpers/form_helper'

class CustomFieldFormBuilder < TabularFormBuilder
  include ActionView::Context
  include ActionView::Helpers::FormTagHelper
  include ActionView::Helpers::FormOptionsHelper
  # Return custom field html tag corresponding to its format
  def custom_field(options = {})
    input = custom_field_input(options)

    if options[:no_label]
      input
    else
      label = custom_field_label_tag
      container_options = options.merge(no_label: true)

      label + container_wrap_field(input, 'field', container_options)
    end
  end

  private

  def possible_options_for_object
    object
      .custom_field
      .possible_values_options(object.customized)
  end

  def custom_field_input(options = {})
    field = :value
    input_options = options.merge(no_label: true,
                                  name: custom_field_field_name,
                                  id: custom_field_field_id)

    field_format = OpenProject::CustomFieldFormat.find_by_name(object.custom_field.field_format)
    formatted_id = input_options[:id].scan(/\d+/).first

    case field_format.try(:edit_as)
    when 'date'
      input_options[:class] = (input_options[:class] || '') << ' -augmented-datepicker'
      text_field(field, input_options)
    when 'text'
      text_area(field, input_options.merge(rows: 3))
    when 'bool'
      formatter = field_format.formatter.new(object)
      check_box(field, input_options.merge(checked: formatter.checked?))
    when 'list'
      custom_field_input_list(field, input_options)
    when 'document'
      apply_selection(field, field_format.try(:edit_as), formatted_id, options[:obj_id], input_options)
    when 'work_package'
      apply_selection(field, field_format.try(:edit_as), formatted_id, options[:obj_id], input_options)
    when 'message'
      apply_selection(field, field_format.try(:edit_as), formatted_id, options[:obj_id], input_options)
    when 'counter'
      if options[:action] == 'edit'
        custom_value = CustomValue.where(:customized_id => options[:obj_id], :custom_field_id => formatted_id).first
        custom_value == nil ? "" : custom_value.value
      end
    when 'formula'
      if options[:obj_id] != nil
        calculate_formula(options[:obj_id], options[:class_name], formatted_id, options[:from])
      end
    when 'rtf'
      text_area(field, input_options.merge(with_text_formatting: true))
    when 'file'
      display_uploaded_files(field, formatted_id, options[:obj_id], input_options)
    else
      text_field(field, input_options)
    end
  end

  # tmd
  def display_uploaded_files(field, custom_field_id, customized_id, input_options)
    data = CustomValue.where(:custom_field_id => custom_field_id, :customized_id => customized_id).pluck(:value)

    if data.any?
      html = ''
      data.each do |filename|
        html += file_field(field, input_options)
        html += '<div class="form--field content--split">'
        html += ActionController::Base.helpers.link_to filename, '/download_file/?filename=' + filename
        html += '</div>'
      end

      ActiveSupport::SafeBuffer.new(html)
    else
      file_field(field, input_options)
    end
  end

  # tmd
  def apply_selection(field, format, custom_field_id, customized_id, input_options)
    val = CustomValue.where(:custom_field_id => custom_field_id, :customized_id => customized_id).pluck(:value)
    selected = nil
    input_options[:multiple] = true
    input_options[:style] = 'height: auto; width: auto'
    input_options[:name] = 'classifier' + custom_field_id + '[]'

    if val.any?
      selected = val[0].split
    end

    case format
    when "work_package"
      select_tag(field, options_for_select(WorkPackage.all.map {|c| [c.subject, c.id]}, selected), input_options)
    when "document"
      select_tag(field, options_for_select(Document.all.map {|c| [c.title, c.id]}, selected), input_options)
    when "message"
      messages = Message.where(:parent_id => nil)
      select_tag(field, options_for_select(messages.map {|c| [c.subject, c.id]}, selected), input_options)
    end
  end

  #tmd
  def calculate_formula(id, name, cf_id, from)
    sql = "SELECT formula FROM custom_fields WHERE type = '" + name + "CustomField' AND id = " + cf_id.to_s
    records_array = ActiveRecord::Base.connection.execute(sql).values
    expr = records_array[0][0].to_s
    is_valid = true
    expr_params = expr.split(/[+\-*\/]/)

    for expr_param in expr_params
      if expr_param =~ /^([^0-9]*)$/
        expr_param = expr_param.strip
        begin
          translation = I18n.backend.translations[:en][:attributes].key expr_param
          query = "SELECT " + translation.to_s + " FROM " + from + " WHERE id = " + id.to_s
          result = ActiveRecord::Base.connection.execute(query).values
          expr = expr.sub(expr_param, result[0][0])
        rescue Exception => e
          is_valid = false
        end
      end
    end

    if is_valid
      result = eval(expr)
    else
      result = "Формула задана неверно!"
    end

    result
  end

  def custom_field_input_list(field, input_options)
    possible_options = possible_options_for_object
    select_options = custom_field_select_options_for_object
    selectable_options = template.options_for_select(possible_options, object.value)

    select(field, selectable_options, select_options, input_options).html_safe
  end

  def custom_field_select_options_for_object
    is_required = object.custom_field.is_required?
    default_value = object.custom_field.default_value

    select_options = {no_label: true}

    if is_required && default_value.blank?
      select_options[:prompt] = "--- #{I18n.t(:actionview_instancetag_blank_option)} ---"
    elsif !is_required
      select_options[:include_blank] = true
    end

    select_options
  end

  def custom_field_field_name
    "#{object_name}[#{object.custom_field.id}]"
  end

  def custom_field_field_id
    "#{object_name}#{object.custom_field.id}".gsub(/[\[\]]+/, '_')
  end

  # Return custom field label tag
  def custom_field_label_tag
    custom_value = object
    is_required = object.custom_field.is_required?

    classes = 'form--label'
    classes << ' error' unless custom_value.errors.empty?
    classes << ' -required' if is_required

    content_tag 'label',
                for: custom_field_field_id,
                class: classes,
                title: custom_value.custom_field.name do
      content_tag('span', custom_value.custom_field.name) +
        (content_tag('span', '*', class: 'form--label-required', :'aria-hidden' => true) if is_required)
    end
  end
end
