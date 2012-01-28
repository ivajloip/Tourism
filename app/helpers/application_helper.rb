module ApplicationHelper
  def menu_links 
    { 'home' => '/', 'articles.name' => articles_path }
  end

  def is_admin
    user_signed_in? and current_user.admin
  end

  def can_edit entity
    user_signed_in? and (entity.user == current_user or current_user.admin)
  end
end
