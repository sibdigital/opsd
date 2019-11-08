
module ClassifierHelper

  def parse_classifier_value(type, class_name, id)
    custom_field_ids = CustomField.where(:type => class_name + 'CustomField', :field_format => ['work_package', 'document', 'message']).pluck(:id)
    custom_field_ids.each do |custom_field_id|
      classifier_value = params['classifier' + custom_field_id.to_s]
      custom_value = CustomValue.where(:customized_type => type, :customized_id => id, :custom_field_id => custom_field_id).first

      if classifier_value.nil?
        custom_value.update_attribute(:value, nil)
      else
        string_value = ''
        classifier_value.each do |val|
          string_value += val.to_s + ' '
        end

        custom_value.update_attribute(:value, string_value)
      end
    end
  end

end
