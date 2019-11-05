require 'rtf-templater'

class ReportMeetingsController < ApplicationController
  include RtfTemplater::Generator
  include Downloadable

  def show
    generate_some_report
    send_to_user filepath: @ready_some_report_path
  end

  def generate_some_report
    meeting = Meeting.find(params[:id])
    @title = meeting.title
    @location = meeting.raion
    @date_meeting = format_date meeting.start_date
    @number_meeting = ''
    @uchastniki = format_participant_list(meeting.participants).push(format_participant_list2(meeting.add_participants)).join(', ')
    @govorili = format_participant_list2(meeting.speakers).join(', ')
    puts @uchastniki
    @chairman = meeting.chairman ? meeting.chairman.fio : ''
    @dolzhnost = meeting.chairman ? meeting.chairman.roles_for_project(meeting.project).sort_by{|r| r.position}.last : ''
    @protocols = []
    meeting.protocols.map do |protocol|
      p = Hash.new()
      p["text"] = protocol.text
      p["due_date"] = format_date protocol.due_date
      p["user"] = protocol.user ? protocol.user.fio : ''
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

  private

  def format_participant_list(participants)
    participants.sort.map { |p| p.user.fio }
  end

  def format_participant_list2(add_participants)
    if add_participants
      add_participants.split(/,/).map { |p| User.find(p).fio }
    else
      []
    end
  end
end
