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

end
