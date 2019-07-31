#-- encoding: UTF-8
# This file written by BBM
# 26/04/2019

module DemoData
  class OrganizationSeeder < Seeder

    def initialize; end

    def seed_data!
      org = translate_with_base_url("seeders.demo_data.organizations")

      org.each do |attributes|
        print '.'

        tr_attr = organization_attributes attributes

        org = Organization.create tr_attr
        org.save!(:validate => false)
        puts org.name
      end
    end

    private

      def organization_attributes(attributes)
      {
        name:         attributes[:name],
        is_legal_entity:  attributes[:is_legal_entity],
        org_type:  find_org_type(attributes[:org_type]).id,
        parent_id:   find_by_name(attributes[:parent]),
        inn: attributes[:inn]
      }
    end

    def find_org_type(name)
      print name
      print OrganizationType.find_by(name: name)
      OrganizationType.find_by(name: name)
    end

    def find_by_name(name)
      o = Organization.find_by(name: name)
      if (o != nil)
        o.id
      end
    end

  end
end
