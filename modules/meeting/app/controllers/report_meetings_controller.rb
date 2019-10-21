require 'rtf-templater'

class ReportMeetingsController < ApplicationController
  include RtfTemplater::Generator
  include Downloadable

  def show
    generate_some_report
    send_to_user filepath: @ready_some_report_path
  end

  def generate_some_report
    puts "Reported"

    meeting = Meeting.find(params[:id])
    @project = meeting.project
    @date_meeting = meeting.start_date.to_s
    @number_meeting = ''
    @chairman = meeting.chairman
    @protocols = meeting.protocols

    dir_path = File.absolute_path('.') + '/public/reports'
    if  !File.directory?(dir_path)
      Dir.mkdir dir_path
    end
    @absolute_path = File.absolute_path('.') +'/'+'app/reports/templates/meeting.rtf'
    @ready_some_report_path = dir_path + '/some_report.doc'
    File.open @absolute_path do |f|
      content = f.read
      f = File.new(@ready_some_report_path, 'w')
      f << render_rtf(content)
      f.close
    end
  end
end
