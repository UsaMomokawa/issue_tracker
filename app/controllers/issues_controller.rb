# noinspection RailsChecklist01
class IssuesController < ApplicationController

  before_action :enforce_login

  def index
    if params[:project_id].present?
      @project = Project.find params[:project_id]
      @issues = @project.issues
    else
      @issues = current_user.issues
    end
  end

  def new
    @project = Project.find params[:project_id]
    @issue = @project.issues.build
  end

  def create
    Issue.transaction do
      @project = Project.find params[:project_id]
      @issue = @project.issues.build params.require(:issue).permit(:title, :content, :deadline, :project_id, :user_id)
      @issue.save!
    end

    redirect_to project_issue_url(@project, @issue)

  rescue ActiveRecord::RecordInvalid
    render action: :new

  end

  def show
    if params[:project_id].present?
      @project = Project.find params[:project_id]
    end

    @issue = Issue.find(params[:id])
  end

  def edit
    if params[:project_id].present?
      @project = Project.find params[:project_id]
    end

    @issue = Issue.find(params[:id])
  end

  def update
    Issue.transaction do
      @issue =
          if params[:project_id].present?
            @project = Project.find params[:project_id]
            @issue = @project.issues.find params[:id]
          else
            Issue.find params[:id]
          end

      @issue.attributes = params.require(:issue).permit(:title, :content, :deadline, :project_id, :user_id)
      @issue.save!
    end

    if @project.present?
      redirect_to project_issue_url(@project, @issue)
    else
      redirect_to issue_url(@issue)
    end

  rescue ActiveRecord::RecordInvalid
    render action: :edit

  end

  def close
    Issue.transaction do
      @issue =
          if params[:project_id].present?
            @project = Project.find params[:project_id]
            @issue = @project.issues.find params[:id]
          else
            Issue.find params[:id]
          end

      @issue.close!
    end

    if @project.present?
      redirect_to project_issue_url(@project, @issue)
    else
      redirect_to issue_url(@issue)
    end
  end
end
