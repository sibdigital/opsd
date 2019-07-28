#-- encoding: UTF-8
# This file written by BBM
# 26/04/2019

module DemoData
  class ProjectRiskSeeder < Seeder

    def initialize; end

    def seed_data!
      risks_data = translate_with_base_url("seeders.demo_data.project_risks")

      risks_data.each do |attributes|
        print '.'

        tr_attr = project_risk_attributes attributes

        risk = ProjectRisk.create tr_attr
      end

      problems = translate_with_base_url("seeders.demo_data.work_package_problems")
      problems.each do |attributes|
        print '.'

        tr_attr = work_package_problem_attributes attributes

        risk = WorkPackageProblem.create tr_attr
      end
    end

    private

    def project_risk_attributes(attributes)
      {
        name:         attributes[:name],
        description:  attributes[:description],
        possibility:  find_possibility(attributes),
        importance:   find_importance(attributes),
        color:     color_by_name(attributes[:color_id]),
        project_id:  project_by_name(attributes[:project])
      }
    end

    def work_package_problem_attributes(attributes)
      project =   project_by_name(attributes[:project])
      wp = work_package_by_subject(attributes[:work_package_subject])
      {
        project_id:  project,
        work_package_id: if wp != nil
                           wp.id
                         end,
        risk_id: find_risk(attributes[:risk], project).id,
        status: attributes[:status],
        #TODO: fix!!!!
        user_creator_id: 1#if wp.assigned_to_id != nil
                          # wp.assigned_to_id
                         #else
                         #  get_user project
                        # end
      }
    end

    def get_user(project_id)
      m = Member.find_by(project_id: project_id)
      m.user_id
    end

    def find_risk(name, project_id)
      #puts ProjectRisk.find_by(name: name)
      ProjectRisk.find_by(name: name, project_id: project_id)
    end

    def work_package_by_subject(subject)
      WorkPackage.find_by(subject: subject)
    end

    def find_possibility(attributes)
      Possibility.find_by(name: translate_with_base_url(attributes[:possibility]))
    end

    def find_importance(attributes)
      Importance.find_by(name: translate_with_base_url(attributes[:importance]))
    end

    def color_by_name(color_name)
      Color.find_by(name: color_name)
    end

    def project_by_name(name)
      np = Project.find_by(name: name)
      if np != nil
        np.id
      end
    end
  end
end
