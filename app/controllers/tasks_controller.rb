class TasksController < ApplicationController

  # GET /tasks
  def index   #Task.all
    @tasks = policy_scope(Task)
  end

  # POST  /tasks/
  def create
    @task = Task.new
    authorize @task
  end

  # PATCH /tasks/:id
  def update
    @task = Task.find(params[:id])
    authorize @task
  end


  # DELETE  /tasks/:id
  def destroy

  end

  # PATCH tasks/:id/complete
  def mark_as_complete
  end
end


