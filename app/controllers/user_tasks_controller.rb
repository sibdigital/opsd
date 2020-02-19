#written by ban
class UserTasksController < ApplicationController

  layout 'my'
  menu_item :my_tasks

  helper :sort
  include SortHelper
  include SortHelper
  include PaginationHelper
  # knm
  # new и edit вью должны рендерить одну и ту же _form, только с разными методами в рендере
  # на _form есть пример того как нужно его заполнить
  # create просто дролжен делать save из params
  # в роутах tasks сделать вложенным ресурсом чтобы index обрабатывался контроллером tasks а не my
  # вопросы можно писать мне в вайбер
  def index
    sort_columns = {'id' => "#{UserTask.table_name}.id",
                    'project' => "#{UserTask.table_name}.project_id",
                    'assigned_to' => "#{UserTask.table_name}.assigned_to_id",
                    'due_date' => "#{UserTask.table_name}.due_date",
                    'completed' => "#{UserTask.table_name}.completed"
    }
    sort_init 'id', 'asc'
    sort_update sort_columns
    @user_tasks = UserTask.all
                    .order(sort_clause)
                    .page(page_param)
                    .per_page(per_page_param)
  end

  def show
    @user_task = UserTask.find(params[:id])
  end

  def new
    @kind_new = params[:kind]
    @user_task = UserTask.new
  end

  def edit
    @user_task = UserTask.find(params[:id])
  end

  def create
    @kind_new = params[:kind]
    @user_task = UserTask.new(user_task_params)
    @user_task.kind = params[:user_task][:kind]
    @user_task.user_creator = User.current
    if @user_task.save
      redirect_to @user_task
      if @user_task.kind == 'Request'
        user = User.find(@user_task.assigned_to_id)
        timenow = Time.now.strftime("%d/%m/%Y %H:%M")
        due_date = @user_task.due_date
        ut_text = @user_task.text
        ut_creator = User.find_by(id: @user_task.user_creator_id).name(:lastname_f_p)
        case @user_task.object_type
        when 'WorkPackage'
          url_to_object = '#'
          begin_text = 'Вам направлен запрос'
          if @user_task.object_id != nil && @user_task.object_id != 0
            if WorkPackage.find(@user_task.object_id)
              url_to_object = work_package_url(WorkPackage.find_by(id: @user_task.object_id))
              link_to_response = new_user_task_url(kind: 'Response', object_type: 'WorkPackage', head_text: 'Ответ на запрос на приемку задачи', project_id: @user_task.project_id, object_id: @user_task.object_id, assigned_to_id: @user_task.user_creator_id, related_task_id: @user_task.id)
              #@link_to_response = Setting.host_name+'/user_tasks/new?assigned_to_id='+@user_task.user_creator_id+'&head_text=Ответ+на+запрос&kind=Response&object_id='+@user_task.object_id+'&object_type='+@user_task.object_type+'&project_id='+ut_project_id+'&related_task_id='+@user_task.id;
              link_to_update = Setting.host_name+'/api/v3/wp_assigned/'+@user_task.object_id.to_s+'/'+@user_task.assigned_to_id.to_s
              begin_text = 'Вам направлен запрос на приемку задачи. В случае согласия нажмите на ссылку для принятия задачи: '+link_to_update+'. В случае несогласия, вы можете написать ответ на запрос. Для этого перейдите по ссылке: '+link_to_response
            end
          end
        when 'Производственные календари'
          url_to_object = Setting.host_name+'/production_calendars'
          begin_text = 'Справочник, в который требуется внести изменения: Производственные календари'
        when 'Типовые риски'
          url_to_object = Setting.host_name+'/admin/typed_risks'
          begin_text = 'Справочник, в который требуется внести изменения: Типовые риски'
        when 'Типовые результаты'
          url_to_object = Setting.host_name+'/admin/typed_targets'
          begin_text = 'Справочник, в который требуется внести изменения: Типовые результаты'
        when 'Уровни контроля'
          url_to_object = Setting.host_name+'/admin/control_levels'
          begin_text = 'Справочник, в который требуется внести изменения: Уровни контроля'
        when 'Перечисления'
          url_to_object = Setting.host_name+'/admin/enumerations'
          begin_text = 'Справочник, в который требуется внести изменения: Перечисления'
        when 'Типы расходов'
          url_to_object = Setting.host_name+'/admin/cost_types'
          begin_text = 'Справочник, в который требуется внести изменения: Типы расходов'
        when 'Национальные проекты'
          url_to_object = Setting.host_name+'/national_projects'
          begin_text = 'Справочник, в который требуется внести изменения: Национальные проекты'
        when 'Государственные программы'
          url_to_object = Setting.host_name+'/national_projects/government_programs'
          begin_text = 'Справочник, в который требуется внести изменения: Государственные программы'
        else
          url_to_object = '#'
          begin_text = ''
        end
        begin
          UserMailer.user_task_request_created(user, url_to_object, begin_text, timenow, due_date, ut_text, ut_creator).deliver_now
        rescue Exception => e
          Rails.logger.info(e.message)
        end
      else
        if @user_task.kind == 'Response'
          @user_task.related_task_id = params[:related_task_id]
        end
      end
    else
      render 'new'
    end
  end

  def update
    @user_task = UserTask.find(params[:id])
    if @user_task.update(user_task_params)
      redirect_to @user_task
    else
      render 'edit'
    end
  end

  def destroy
    @user_task = UserTask.find(params[:id])
    @user_task.destroy
    redirect_to user_tasks_path
  end

  private
  def user_task_params
    params.require(:user_task).permit(:project_id, :user_creator_id, :assigned_to_id, :object_id, :object_type, :kind,
                                      :text, :due_date, :completed, :related_task_id, :period_id)
  end
end
