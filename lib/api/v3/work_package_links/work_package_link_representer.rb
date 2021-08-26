module API
  module V3
    module WorkPackageLinks
      class WorkPackageLinkRepresenter < ::API::Decorators::Single
        include API::Decorators::LinkedResource
        property :id
        property :link
        property :name
        associated_resource :author,
                            v3_path: :user,
                            representer: ::API::V3::Users::UserRepresenter
        associated_resource :work_package,
                            v3_path: :work_package,
                            link_title_attribute: :subject,
                            representer: ::API::V3::WorkPackages::WorkPackageRepresenter
        property :created_at
        property :updated_at
        link :self do
          { href: api_v3_paths.link(represented.id) }
        end
        link :delete do
            {
                href: api_v3_paths.link(represented.id),
                method: :delete,
                title: 'Remove link'
            }
        end
        link :update do
            { href: api_v3_paths.link(represented.id), method: :patch, title: 'Update link' }
        end
        def _type
          @_type ||= "Work Package Link"
        end
      end
    end
  end
end
