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

  def content article
    escaped = ERB::Util.html_escape(article.content)

    parse_images(escaped).html_safe
  end

private  
  def parse_images(text)
    logger.debug("Parsing ----#{text}----")
    text.gsub(/\[([^\]\n\r]+?)\]\(([^\)\s]+?)\)/, '<img src="\2" alt="\1" />')
  end
end
