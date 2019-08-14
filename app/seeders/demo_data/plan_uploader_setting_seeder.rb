#-- encoding: UTF-8

module DemoData
  class PlanUploaderSettingSeeder < Seeder

    def initialize; end

    def seed_data!
      settings = translate_with_base_url("seeders.demo_data.plan_uploader_settings")

      settings.each do |attributes|
        print '.'
        setting = new_setting attributes
        unless setting.save!
          puts 'Seeding plan_uploader_setting failed:'
          setting.errors.full_messages.each do |msg|
            puts "  #{msg}"
          end
        end
      end

    end

    private

    def new_setting(attributes)
      PlanUploaderSetting.new.tap do |s|
        s.column_name  =        attributes[:column_name]
        s.column_num =         attributes[:column_num]
        s.is_pk  =   attributes[:is_pk]
        s.table_name  =   attributes[:table_name]
      end
    end
  end
end
