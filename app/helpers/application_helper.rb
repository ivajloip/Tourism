module ApplicationHelper
  def menu_links 
    links = { 'home' => '/', 'articles.name' => articles_path, 
              'articles.search.title' => search_articles_path }

    if user_signed_in? 
      if current_user.admin?
        links = links.merge({ 'tags.list' => tags_path, 'provinces.list' => provinces_path })
      end

      links = links.merge({ 'articles.new' => new_article_path, 'user.profile' => edit_user_path(current_user),
                            'users.list' => users_path, 'users.logout' => logout_path })
    else
      links = links.merge({ 'users.sign_in' => new_user_session_path, 
                            'users.sign_up' => new_user_registration_path })
    end

    links
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

  def pagination_url url, page, keep_url = false
    if keep_url
      url
    else
      url.split('?')[0] + '?page=' + page.to_s
    end
  end

  def follow_buttons entity
    if user_signed_in? and not entity.following.include?(current_user)
      button_to t("button.follow"), { :action => "follow" }, :method => :put, :remote => true
    else
      button_to t("button.unfollow"), { :action => "unfollow" }, :method => :put, :remote => true
    end
  end
end
