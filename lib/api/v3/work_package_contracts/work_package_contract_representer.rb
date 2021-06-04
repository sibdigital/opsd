module API
  module V3
    module WorkPackageContracts
      class WorkPackageContractRepresenter < ::API::Decorators::Single
        include API::Decorators::LinkedResource
        property :id
        property :comment
        associated_resource :contract,
                            v3_path: :contract,
                            link_title_attribute: :contract_subject,
                            representer: ::API::V3::Contracts::ContractRepresenter
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
          { href: api_v3_paths.work_package_contract(represented.id) }
        end
        link :delete do
          {
              href: api_v3_paths.work_package_contract(represented.id),
              method: :delete,
              title: 'Remove contract link'
          }
        end
        link :update do
          { href: api_v3_paths.work_package_contract(represented.id), method: :patch, title: 'Update contract link' }
        end
        def _type
          @_type ||= "Work Package Contract"
        end
      end
    end
  end
end
