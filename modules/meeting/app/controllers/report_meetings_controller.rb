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
    #temp_date_meeting = Date.strptime(meeting.start_date.to_s, "%Y-%m-%d")
    @date_meeting = format_date meeting.start_date
    @number_meeting = ''
    @chairman = meeting.chairman.fio
    @protocols = []
    meeting.protocols.map do |protocol|
      p = Hash.new()
      p["text"] = protocol.text
      p["due_date"] = format_date protocol.due_date
      p["user"] = protocol.user.fio
      p["org"] = protocol.user.organization
      @protocols << p
    end
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

  def format_date(date)
    I18n.l date.to_date, format: :long if date
  end
end
