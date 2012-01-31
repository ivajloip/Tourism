module ApplicationHelper
  def menu_links 
    { 'home' => '/', 'articles.name' => articles_path }
  end

  def is_admin
    user_signed_in? and current_user.admin
  end

  def can_edit entity
    user_signed_in? and (entity.author == current_user or current_user.admin)
  end

  def rerender id, partial
    result = "$('#%s').html('%s');" % [id, escape_javascript(render(partial))]
    result.html_safe
  end

  def pagination_url vars, page
    custom_url = vars.eval("custom_url ||= nil")
    url = custom_url || vars.eval("url").split('?')[0]
    url + '?page=' + page.to_s
  end
end
