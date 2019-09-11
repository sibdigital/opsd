#written by ban
class UserTasksController < ApplicationController

  def index
    @user_tasks = UserTask.all
  end

  def show
    @user_task = UserTask.find(params[:id])
  end

  def new
    @kind_new = params[:kind]
    @user_task = UserTask.new
    @object_types = object_types
  end

  def edit
    @user_task = UserTask.find(params[:id])
    @object_types = object_types
  end

  def create
    @kind_new = params[:kind]
    @user_task = UserTask.new(user_task_params)
    @user_task.kind = params[:user_task][:kind]
    @user_task.user_creator = User.current
    if @user_task.save
      redirect_to @user_task
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

  def object_types
    object_types = []
    object_types << 'WorkPackage'
    object_types << 'Organization'
    object_types
  end

  def kinds
    kinds = []
    kinds << 'Task'
    kinds << 'Note'
    kinds << 'Request'
    kinds << 'Response'
    kinds
  end

  private
  def user_task_params
    params.require(:user_task).permit(:project_id, :user_creator_id, :assigned_to_id, :object_id, :object_type, :kind,
                                      :text, :due_date, :completed, :related_task_id)
  end
end
