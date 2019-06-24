#-- encoding: UTF-8
# This file written by BBM
# 24/06/2019
require 'api/v3/attach_types/attach_type_collection_representer'
require 'api/v3/attach_types/attach_type_representer'

module API
  module V3
    module AttachTypes
      class AttachTypesAPI < ::API::OpenProjectAPI
        resources :attachTypes do
          before do
            authorize(:view_work_packages, global: true)

            @attach_types = AttachType.all
          end

          get do
            AttachTypeCollectionRepresenter.new(@attach_types,
                                              api_v3_paths.attach_types,
                                              current_user: current_user)
          end

          route_param :id do
            before do
              @attach_type = AttachType.find(params[:id])
            end

            get do
              AttachTypeRepresenter.new(@attach_type, current_user: current_user)
            end
          end
        end
      end
    end
  end
end
