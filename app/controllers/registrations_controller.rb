class RegistrationsController < Devise::RegistrationsController
  def create
    build_resource
    if verify_recaptcha(@user)
      super
    else
      render :action => :new, :notice => 'Incorrect Capture'
    end
  end
end
