class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_locale

  def initialize 
    @page_size = 2
    super
  end
   
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def is_admin
    logger.debug "Controller is there #{self}. "

    if user_signed_in? and current_user.admin
      true
    else
      flash[:error] = I18n.t 'unsufficient_privileges'
      redirect_to :action => 'index'

      false
    end
  end

  def verify_edit_permissions entity
    unless entity.editable_by?(current_user)
      logger.debug "Redirected #{current_user} who was tring to edit #{entity}"

      flash[:error] = I18n.t 'unsufficient_privileges', :default => 'You don\'t have the persmissions required to edit this document'
      redirect_to entity
    end
  end

private 
  def add_opinion success_message, failure_message
    entity, container = yield

    if entity.save
      respond_to do |format|
        format.html { redirect_to container, notice: success_message }
        format.json { head :ok }
        format.js { render 'votes' }
      end
    else 
      respond_to do |format|
        format.html { redirect_to container, notice: failure_message }
        format.json { render json: comment.errors, status: :unprocessable_entity }
      end
    end
  end
end
