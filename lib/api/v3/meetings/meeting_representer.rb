require 'roar/decorator'
require 'roar/json/hal'

module API
  module V3
    module Meetings
      class MeetingRepresenter < ::API::Decorators::Single
        #include ::API::Caching::CachedRepresenter

        self_link path: :meeting,
                  title_getter: ->(*) { represented.title }

        property :id, render_nil: true

        property :title, render_nil: true

        property :location, render_nil: true

        property :start_time,
                 render_nil: true,
                 exec_context: :decorator,
                 getter: ->(*) { datetime_formatter.format_datetime(represented.start_time) }

        property :agenda_text,
                 render_nil: true,
                 exec_context: :decorator,
                 getter: ->(*) { represented.agenda.text }

        property :participant_list,
                 render_nil: true,
                 exec_context: :decorator,
                 getter: ->(*) { represented.participants.sort.map { |p| p.user }.join('; ').html_safe }

        property :workPackageId,
                 exec_context: :decorator,
                 getter: ->(*) { represented.work_package.id }

        def _type
          'Meeting'
        end
      end
    end
  end
end
