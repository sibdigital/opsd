#-- encoding: UTF-8
#by zbd
#++

require 'api/v3/work_package_problems/work_package_problem_representer'
require 'api/v3/work_package_problems/work_package_problem_collection_representer'

module API
  module V3
    module WorkPackageProblems
      class WorkPackageProblemsAPI < ::API::OpenProjectAPI
        resources :work_package_problems do
          before do
            authorize(:view_work_package_problems, global: true)
            @work_package_problems = if params[:work_package_id].nil?
                                       WorkPackageProblem.all
                                     else
                                       WorkPackageProblem
                                         .where('work_package_id = ?', params[:work_package_id])
                                         #.order('risk_id asc')
                                     end
          end

          get do
            WorkPackageProblemCollectionRepresenter.new(@work_package_problems,
                                           api_v3_paths.work_package_problems,
                                           current_user: current_user)
          end

          #TODO (zbd) добавить проверку на выполнение операции в соответствии с ролевой моделью
          post do
            authorize(:manage_work_package_problems, global: true)

            work_package_problem = WorkPackageProblem.new
            work_package_problem.risk_id = params[:risk_id]
            work_package_problem.project_id = params[:project_id]
            work_package_problem.work_package_id = params[:work_package_id]
            work_package_problem.user_creator_id = current_user.id
            work_package_problem.user_source_id = params[:user_source_id] #User.find(params[:user_source_id]).id
            work_package_problem.organization_source_id = params[:organization_source_id] #Organization.find(params[:organization_source_id]).id
            work_package_problem.type = params[:type]
            work_package_problem.status = params[:status]
            work_package_problem.solution_date = params[:solution_date]
            work_package_problem.description = params[:description]
            work_package_problem.save

            WorkPackageProblemCollectionRepresenter.new(@work_package_problems,
                                                       api_v3_paths.work_package_problems,
                                                       current_user: current_user)
          end

          route_param :id do
            get do
              authorize(:view_work_package_problems, global: true)
              @work_package_problem = WorkPackageProblem.find(params[:id])
              WorkPackageProblemRepresenter.new(@work_package_problem,
                                               current_user: current_user)
            end

            delete do
              #project = Project.find params[:project_id]

              authorize :manage_work_package_problems, global: true #context: project

              WorkPackageProblem.destroy params[:id]
              status 204
            end

            patch do
              authorize :manage_work_package_problems, global: true #context: project

              #@work_package_problem = WorkPackageProblem.find(params[:id])

              WorkPackageProblem.update params[:id], params
            end
          end
        end
      end
    end
  end
end
