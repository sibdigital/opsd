#-- encoding: UTF-8
#by zbd
#++

require 'api/v3/boards/board_representer'
require 'api/v3/boards/board_collection_representer'

module API
  module V3
    module Boards
      class BoardsAPI < ::API::OpenProjectAPI
        resources :boards do
          before do
            authorize(:view_work_packages, global: true)
            @boards = Board.all
          end

          get do
            BoardCollectionRepresenter.new(@boards,
                                              api_v3_paths.boards,
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
            topics = Message.find_by_sql(
               "select *
                from messages
                where parent_id IS NULL and locked = false" #TODO только для открытых проектов
            )
            elements = []
            topics.each do |topic|
              elements.push({
                id: topic.id,
                subject: topic.subject,
                content: topic.content,
                author: topic.author,
                board: topic.board,
                project: topic.project
              })
            end
            elements
          end
        end

      end
    end
  end
end
