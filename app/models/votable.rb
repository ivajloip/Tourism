module Votable
  def like(user)
    disliking_ids.delete(user._id)

    unless liking_ids.include? user._id
      liking_ids << user._id
    end
  end

  def dislike(user)
    liking_ids.delete(user._id)

    unless disliking_ids.include? user._id
      disliking_ids << user._id
    end
  end

  def liking_count
    liking_ids.blank? ? 0 : liking_ids.count
  end

  def disliking_count
    disliking_ids.blank? ? 0 : disliking_ids.count
  end
end
