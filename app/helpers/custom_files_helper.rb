# tmd
module CustomFilesHelper

  mattr_accessor :file_names
  mattr_accessor :file_ids

  def upload_custom_file(object_type, custom_field_type)
    @file_ids = CustomField.where(:field_format => 'file', :type => custom_field_type + 'CustomField').pluck(:id)
    @file_names = []

    @file_ids.each do |id|
      begin
        uploaded_file = params[object_type][:custom_field_values][id.to_s]

        if uploaded_file != nil
          @file_names << uploaded_file.original_filename

          path = Rails.root.join('public', 'uploads', 'custom_fields')
          FileUtils.mkdir_p(path) unless File.exist?(path)

          File.open(File.join(path, uploaded_file.original_filename), 'wb') do |file|
            file.write(uploaded_file.read)
          end
        end
      rescue

      end
    end
  end


  def assign_custom_file_name(type, id)
    for i in 0...@file_ids.length
      CustomValue.where(:customized_type => type, :custom_field_id => @file_ids[i], :customized_id => id).update(:value => @file_names[i])
    end
  end

end
