#-- encoding: UTF-8
#by zbd
#++

require 'roar/decorator'
require 'roar/json/hal'

module API
  module V3
    module Boards
      class MessageRepresenter < ::API::Decorators::Single
        include ::API::Caching::CachedRepresenter

        self_link title_getter: ->(*) { represented.subject }

        def initialize(model, current_user:, embed_links: false)
          @current_user = current_user

          super(model, current_user: current_user, embed_links: false)
        end

        property :id, render_nil: true
        property :board, render_nil: true
        property :content, render_nil: true
        property :subject, render_nil: true
        property :parent, render_nil: true
        property :created_on, render_nil: true,
                 exec_context: :decorator,
                 getter: ->(*) { datetime_formatter.format_datetime(represented.created_on) }
        property :updated_on, render_nil: true,
                 exec_context: :decorator,
                 getter: ->(*) { datetime_formatter.format_datetime(represented.updated_on) }
        property :locked, render_nil: true
        property :sticky, render_nil: true
        property :work_package, render_nil: true
        property :replies_count, render_nil: true
        property :author, render_nil: true
        property :project,
                 getter: ->(*) {
                   API::V3::Projects::ProjectRepresenter.new(project, current_user: User.current)
                 }
        property :last_reply

        def _type
          'Message'
        end
      end
    end
  end
end
