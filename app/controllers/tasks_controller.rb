class TasksController < ApplicationController

  # GET /tasks
  def index   #Task.all
    @tasks = policy_scope(Task)
  end

  # POST  /tasks/
  def create
    @task = Task.new(task_params)
    authorize @task
    @task.user = current_user
    if @task.save
      flash[:notice] = "Your new task has been added."
    redirect_to tasks_path
    else
      render "index"
    end
  end

  # PATCH /tasks/:id
  def update
    @task = Task.find(params[:id])
    authorize @task
    @task.save
  end


  # DELETE  /tasks/:id
  def destroy
    @task = Task.find(params[:id])
    authorize @task
    @task.destroy
    redirect_to tasks_path

  end

  # PATCH tasks/:id/complete
  def mark_as_complete
  end

private

def task_params
    params.require(:task).permit(:description)
  end

end


