# tmd
module CounterHelper

  def init_counter_value(type, class_name, id)
    data = CustomField.where(:type => class_name + 'CustomField', :field_format => 'counter')

    if data.any?
      data.each do |element|
        counter_value = CounterValue.new
        custom_value = CustomValue.where(:customized_id => id, :customized_type => type, :custom_field_id => element.id).first

        if custom_value.present?
          counter_setting = CounterSetting.where(:custom_field_id => element.id).first
          latest_counter_record = CounterValue.order('created_at ASC').where(:type_of => type, :custom_field_id => element.id).last
          periodicity = Enumeration.where(:id => counter_setting.period).first

          counter_value.custom_value_id = custom_value.id
          counter_value.counter_setting_id = counter_setting.id
          counter_value.custom_field_id = element.id
          counter_value.type_of = type

          if latest_counter_record.present?
            if periodicity.present?
              if periodicity.name == I18n.t(:default_period_monthly)
                date = Date.today.at_beginning_of_month
              else
                date = Date.today.at_beginning_of_year
              end

              if date > latest_counter_record.created_at
                counter_value.value = 1
              else
                counter_value.value = latest_counter_record.value + 1
              end
            else
              counter_value.value = latest_counter_record.value + 1
            end
          else
            counter_value.value = 1
          end

          counter_value.save

          template = counter_setting.template
          template.gsub! '{i}', counter_value.value.to_s
          template.gsub! '{d}', counter_value.created_at.to_s

          custom_value.update_attribute(:value, template)
        end

      end
    end
  end

    # def destroy_counter_value(type, id)
    #   data = CustomValue.where(:customized_type => type, :customized_id => id).pluck(:id)
    #
    #   if data.any?
    #     CounterValue.where(:custom_value_id => data[0]).destroy_all
    #   end
    # end

end
