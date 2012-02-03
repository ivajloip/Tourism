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

  def rerender_partial id, partial
    rerender id do
      render partial
    end
  end

  def rerender id
    content = yield
    "$('##{id}').html('#{escape_javascript(content)}');".html_safe
  end

  def pagination_url url, page
    url.split('?')[0] + '?page=' + page.to_s
  end
end
