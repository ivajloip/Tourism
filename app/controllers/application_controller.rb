class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_locale
   
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
    unless entity.user == current_user or current_user.admin
      logger.debug "Redirected #{current_user} who was tring to edit #{entity}"
      flash[:error] = I18n.t 'unsufficient_privileges'
      redirect_to :action => 'show'
    end
  end
end
