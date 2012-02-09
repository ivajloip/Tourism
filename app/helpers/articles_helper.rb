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

  def link_to_edit article
    if article.editable_by?(current_user)
      link_to t('edit', :default => 'Edit'), edit_article_path(article)
    else 
      ''
    end
  end

  def link_to_delete article
    if article.editable_by?(current_user)
      confirmation = t 'confirm', :default => 'Are you sure?'
      link_to t('destroy', :default => 'Destroy'), article, confirm: confirmation, method: :delete
    else 
      ''
    end
  end
end
