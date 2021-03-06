#-- copyright
# OpenProject Meeting Plugin
#
# Copyright (C) 2011-2014 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See doc/COPYRIGHT.md for more details.
#++

module MeetingsHelper
  def format_participant_list(participants)
    participants.sort.map { |p| link_to_user p.user }.join('; ').html_safe
  end

  #bbm(
  def format_participant_list2(add_participants)
    add_participants.split(/,/).map { |p| link_to_user User.find(p) }.join('; ').html_safe if add_participants
  end
  # )
  # knm+
  def form_participant_list_of_board(participants)
    participants.sort.map { |p| link_to(p.user.fio, user_path(p.user.id), {class: '', title: p.viewed_at.nil? ? "Не заходил" : "Заходил "+format_activity_day(p.viewed_at)+" в "+format_time(p.viewed_at,false) })}.join('; ').html_safe
  end
  # -
  def render_meeting_journal(model, journal, options = {})
    return '' if journal.initial?
    journal_content = render_journal_details(journal, :label_updated_time_by, model, options)
    content_tag 'div', journal_content,  id: "change-#{journal.id}", class: 'journal'
  end

  # This renders a journal entry with a header and details
  def render_journal_details(journal, header_label = :label_updated_time_by, model = nil, options = {})
    header = <<-HTML
      <div class="profile-wrap">
        #{avatar(journal.user)}
      </div>
      <h4>
        <div class="journal-link" style="float:right;">#{link_to "##{journal.anchor}", anchor: "note-#{journal.anchor}"}</div>
        #{authoring journal.created_at, journal.user, label: header_label}
        #{content_tag('a', '', name: "note-#{journal.anchor}")}
      </h4>
    HTML

    if journal.details.any?
      details = content_tag 'ul', class: 'details journal-attributes' do
        journal.details.map { |detail|
          if d = journal.render_detail(detail, cache: options[:cache])
            content_tag('li', d.html_safe)
          end
        }.compact.join(' ').html_safe
      end
    end

    content_tag('div', "#{header}#{details}".html_safe, id: "change-#{journal.id}", class: 'journal')
  end
end
