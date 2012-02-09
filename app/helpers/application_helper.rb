module ApplicationHelper
  def menu_links 
    links = { 'home' => '/', 'articles.name' => articles_path }

    if user_signed_in? 
      links = links.merge({ 'article.new' => new_article_path, 'user.profile' => edit_user_path(current_user) })

      if current_user.admin?
        links = links.merge({ 'users.title' => users_path })
      end
    else
      links = links.merge({ 'user.sign_in' => new_user_session_path, 'sign_up' => new_user_registration_path })
    end

    links
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
