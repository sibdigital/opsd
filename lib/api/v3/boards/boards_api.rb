#-- encoding: UTF-8
#by zbd
#++

require 'api/v3/boards/board_representer'
require 'api/v3/boards/board_collection_representer'

module API
  module V3
    module Boards
      class BoardsAPI < ::API::OpenProjectAPI
        helpers ::API::V3::Utilities::RoleHelper
        helpers ::API::Utilities::ParamsHelper
        
        resources :boards do
          before do
            authorize(:view_work_packages, global: true)
            @boards = Board.all
          end

          get do
            BoardCollectionRepresenter.new(@boards,
                                           api_v3_paths.boards,
                                           page: to_i_or_nil(params[:offset]),
                                           per_page: resolve_page_size(params[:pageSize]),
                                           current_user: current_user)
          end

          route_param :id do
            before do
               @board = Board.find(params[:id])
             end
            get do
              BoardRepresenter.new(@board, current_user: current_user)
            end
          end
        end

        resources :topics do
          before do
            authorize(:view_work_packages, global: true)
          end

          get do
            projects = [0]
            Project.all.each do |project|
              exist = which_role(project, current_user, global_role)
              if exist
                projects << project.id
              end
            end
            topics = Message
                       .joins(:board)
                       .where("#{Message.table_name}.parent_id IS NULL and locked = false and boards.project_id in (" + projects.join(",")+ ")")#.find_by_sql(
            #    "select *
            #     from messages
            #     where parent_id IS NULL and locked = false" #TODO только для открытых проектов
            # )
            MessageCollectionRepresenter.new(topics,
                                             api_v3_paths.topics,
                                             page: to_i_or_nil(params[:offset]),
                                             per_page: resolve_page_size(params[:pageSize]),
                                             current_user: current_user)
            # elements = []
            # topics.each do |topic|
            #   last_message = topic
            #   if (topic.last_reply_id != nil)
            #     last_message = Message.find(topic.last_reply_id)
            #   end
            #   elements.push({
            #     id: topic.id,
            #     subject: topic.subject,
            #     content: topic.content,
            #     author: topic.author,
            #     board: BoardRepresenter.new(topic.board, current_user: current_user),
            #     project: API::V3::Projects::ProjectRepresenter.new(topic.project, current_user: current_user),
            #     last_message: last_message
            #   })
            # end
            # elements
          end
        end

      end
    end
  end
end
