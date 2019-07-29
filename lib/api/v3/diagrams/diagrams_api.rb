#-- encoding: UTF-8
# This file written by BBM
# 16/07/2019
require 'api/v3/diagrams/diagram_representer'

module API
  module V3
    module Diagrams
      class DiagramsAPI < ::API::OpenProjectAPI
        resources :diagrams do
          before do
            authorize(:view_work_packages, global: true)
          end

          get do
            DiagramRepresenter.new(params: params, current_user: current_user)
          end

          route_param :name do
            get do
              DiagramHomescreenRepresenter.new(name: params[:name], current_user: current_user)
            end
          end
        end
      end
    end
  end
end
