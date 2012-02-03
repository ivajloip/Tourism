module ArticlesHelper
  def votes entity
    result = []
    if entity.respond_to? :liking_count
      result << "#{entity.liking_count} #{I18n.t 'liking'}"
    end

    if entity.respond_to? :disliking_count
      result << "#{entity.disliking_count} #{I18n.t 'disliking'}"
    end

    if entity.respond_to? :following_count
      result << "#{entity.following_count} #{I18n.t 'following'}"
    end

    result.join(', ')
  end

  def follow_buttons
    if user_signed_in? and not @article.following.include?(current_user)
      button_to t("button.follow"), { :action => "follow" }, :method => :put, :remote => true
    else
      button_to t("button.unfollow"), { :action => "unfollow" }, :method => :put, :remote => true
    end
  end
end
