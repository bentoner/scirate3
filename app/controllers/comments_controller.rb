class CommentsController < ApplicationController
  before_filter :find_comment, :only => [:edit, :destroy, :upvote, :downvote, :unvote, :report, :unreport]

  def create
    @comment = current_user.comments.build(params[:comment])

    if @comment.save
      flash[:success] = "Comment posted."
    else
      flash[:error] = "Error posting comment."
    end

    redirect_to @comment.paper
  end

  def edit
    if @comment.user_id == current_user.id
      @comment.content = params['content']
      @comment.save
      render :text => 'success'
    else
      render :status => :forbidden
    end
  end

  def index
    @comments = Comment.paginate(page: params[:page]).includes(:paper, :user).find(:all, order: "created_at DESC")
  end

  def destroy
    if @comment.user_id == current_user.id
      @comment.delete
      flash[:success] = "Comment deleted."
      redirect_to request.referer
    else
      render :status => :forbidden
    end
  end

  def upvote
    @comment.upvote_from(current_user)
    render :text => 'success'
  end

  def downvote
    @comment.downvote_from(current_user)
    render :text => 'success'
  end

  def unvote
    @comment.unvote(voter: current_user)
    render :text => 'success'
  end

  def report
    @comment.reports.create(:user_id => current_user.id)
    render :text => 'success'
  end

  def unreport
    @comment.reports.where(voter_id: current_user.id).destroy_all
    render :text => 'success'
  end

  protected
    def find_comment
      @comment = Comment.find(params[:id])
    end
end
