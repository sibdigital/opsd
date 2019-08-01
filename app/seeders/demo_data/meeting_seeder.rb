#-- encoding: UTF-8
# This file written by BBM
# 01/08/2019

module DemoData
  class MeetingSeeder < Seeder

    def initialize; end

    def seed_data!
      meetings = translate_with_base_url("seeders.demo_data.meetings")
      meeting_contents = translate_with_base_url("seeders.demo_data.meeting_contents")
      meeting_protocols = translate_with_base_url("seeders.demo_data.meeting_protocols")


      meetings.each do |attributes|
        print '.'
        tr_attr = meetings_attributes(attributes)
        targ = Meeting.create tr_attr
        targ.save!
      end

      meeting_contents.each do |attributes|
        print '.'
        tr_attr = meeting_contents_attributes(attributes)
        targ = MeetingContent.create tr_attr
        targ.save!
      end

      meeting_protocols.each do |attributes|
        print '.'
        tr_attr = meeting_protocols_attributes(attributes)
        targ = MeetingProtocol.create tr_attr
        targ.save!
      end

    end

    private

    def meetings_attributes(attributes)
      puts attributes[:author]
      {
        title:         attributes[:title],
        author_id:      user_by_login(attributes[:author]).id,
        project_id:    project_by_name(attributes[:project]),
        duration:      attributes[:duration],
        work_package_id: work_package_by_subject(attributes[:work_package_subject]).id
      }
    end

    def meeting_contents_attributes(attributes)
      {
        meeting_id: meeting_by_title(attributes[:meeting]).id,
        type:       attributes[:type],
        author_id:     user_by_login(attributes[:author]).id,
        text:       attributes[:text]
      }
    end

    def meeting_protocols_attributes(attributes)
      {
        meeting_contents_id: meeting_content_by_text(attributes[:meeting_content]).id,
        #author_id:     user_by_login(attributes[:author]).id,
        assigned_to_id:     user_by_login(attributes[:assigned_to]).id,
        due_date:   Date.today + attributes[:due],
        text:       attributes[:text]
      }
    end

    def meeting_by_title(title)
      Meeting.find_by(title: title)
    end

    def meeting_content_by_text(text)
      MeetingContent.find_by(text: text)
    end

    def work_package_by_subject(subject)
      WorkPackage.find_by(subject: subject)
    end

    def project_by_name(name)
      np = Project.find_by(name: name)
      if np != nil
        np.id
      end
    end

    def user_by_login(login)
      np = User.find_by(login: login)
      if np != nil
        np
      end
    end
  end
end
