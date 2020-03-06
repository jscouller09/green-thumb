class TasksController < ApplicationController

  # GET /tasks
  def index   #Task.all
    @tasks = policy_scope(Task).where(completed: false)
    @task = Task.new
    @user = @task.user_id
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
  # GET /tasks/:id/edit
  def edit
    @tasks = policy_scope(Task).where(completed: false)
    @task = Task.find(params[:id])
    authorize @task
    render 'index'
  end

  # PATCH /tasks/:id
  def update
    @task = Task.find(params[:id])
    authorize @task
    if @task.update(task_params)
      redirect_to tasks_path
    else
      render 'index'
    end
  end


  # DELETE  /tasks/:id
  def destroy
    @task = Task.find(params[:id])
    authorize @task
    @task.destroy
    flash[:notice] = "Your task has been deleted."
    redirect_to tasks_path

  end

  # PATCH tasks/:id/complete
  def mark_as_complete
    @task = Task.find(params[:id])
    authorize @task
    @task.update(completed: true)
    redirect_to tasks_path
  end

private

def task_params
    params.require(:task).permit(:description, :due_date, :priority)
end

end


