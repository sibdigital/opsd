#-- encoding: UTF-8

# This file written by BBM
# 16/07/2019

module API
  module V3
    module Diagrams
      class BubbleDiagramRepresenter < ::API::Decorators::Single
        include ::API::V3::Utilities::RoleHelper

        def initialize(params:, current_user:, global_role:)
          @name = params[:name]
          @project = params[:project]
          @current_user = current_user
          @global_role = global_role
        end

        property :data,
                 exec_context: :decorator,
                 getter: ->(*) {
                   result = []
                   projects = if @project and @project != '0'
                                Project.visible(current_user).where(id: @project)
                                  .or(Project.visible(current_user).where(parent_id: @project))
                                  .order(invest_amount: :desc).all
                              else
                                Project.visible(current_user).order(invest_amount: :desc).all
                              end
                   rmax = 0
                   xmax = 0
                   ymax = 0
                   projects.each do |project|
                     exist = which_role(project, @current_user, @global_role)
                     if exist
                       id = project.parent_id || project.id
                       x = id % 10
                       y = (id / 10).round + 1
                       r = project.invest_amount ? project.invest_amount.to_f : 0
                       rmax = r if r > rmax
                       xmax = x if x > xmax
                       ymax = y if y > ymax
                       result << {x: x, y: y, r: r, id: id}
                     end
                   end
                   result.each {|hash|
                     hash[:r] = rmax == 0 ? 0 : (hash[:r] * 100 / rmax ).round
                     hash[:x] = hash[:x] * 3.5 / xmax
                     hash[:y] = hash[:y] * 1.5 / ymax
                   }
                   result
                 },
                 render_nil: true

        property :label,
                 exec_context: :decorator,
                 getter: ->(*) {
                   result = []
                   projects = if @project and @project != '0'
                                Project.visible(current_user).where(id: @project)
                                  .or(Project.visible(current_user).where(parent_id: @project))
                                  .order(invest_amount: :desc).all
                              else
                                Project.visible(current_user).order(invest_amount: :desc).all
                              end
                   projects.each do |project|
                     exist = which_role(project, @current_user, @global_role)
                     if exist
                       result << project.name + ' ' + project.invest_amount.to_s
                     end
                   end
                   result
                 },
                 render_nil: true

        def _type
          'BubbleDiagram'
        end
      end
    end
  end
end
