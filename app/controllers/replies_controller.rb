class RepliesController < ApplicationController
  before_filter :require_login
  before_filter :find_user
  before_action :build_new_reply_from_params, :only => [:index, :create]
  before_action :find_reply, :only => [:edit, :update, :destroy]
  before_action :find_replies, :only => [:index, :create]
  before_action :update_reply_from_params, :only => [:update]

  def index
    #
  end

  def create
    unless @reply.save
      render :action => 'index'
      return
    end

    flash[:notice] = l(:notice_reply_successful_create)
    redirect_to replies_path
  end

  def preview
    @body = params[:reply] ? params[:reply][:body] : nil

    render :layout => false
  end

  def edit
    #
  end

  def update
    unless @reply.save
      render :action => 'edit'
      return
    end

    flash[:notice] = l(:notice_reply_successful_update)
    redirect_to replies_path
  end

  def destroy
    @reply.destroy

    flash[:notice] = l(:notice_reply_successful_delete)

    redirect_to replies_path
  end

  private

  def find_user
    render_403 unless User.current.allowed_to_create_replies?

    @user = User.current
  end

  def build_new_reply_from_params
    @reply = Reply.new
    @reply.user ||= User.current

    update_reply_from_params
  end

  def update_reply_from_params
    attrs = (params[:reply] || {}).deep_dup

    @reply.safe_attributes = attrs
  end

  def find_reply
    reply_id = params[:reply_id] || params[:id]

    @reply = Reply.find(reply_id)
    raise Unauthorized unless @reply.visible?
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_replies
    @replies = @user.replies.order('name ASC')
  end
end
