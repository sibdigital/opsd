require 'api/v3/meetings/meeting_representer'
require 'api/v3/meetings/meeting_collection_representer'

module API
  module V3
    module Meetings
      class MeetingsAPI < ::API::OpenProjectAPI
        resources :meetings do
          get do
            begin
            meetings = if params[:project_identifier].nil? || params[:project_identifier] == 'undefined'
                          Meeting.all
                       else
                          project_id = Project.find_by(identifier: params[:project_identifier]).id;
                          puts project_id
                          Meeting.where('project_id = ?', project_id)
                       end
            rescue Exception => e
              meetings = Meeting.all
            end
            MeetingCollectionRepresenter.new(meetings,
                                              api_v3_paths.meetings,
                                              current_user: current_user)
          end

          params do
            requires :id, desc: 'Meeting id'
          end

          route_param :id do
            before do
              @meeting = Meeting.find(params[:id])
            end

            get do
              MeetingRepresenter.new(@meeting, current_user: current_user)
            end
          end
        end
      end
    end
  end
end
