module Followable
  def follow(user)
    unless following_ids.include? user._id
      following << user
    end
  end

  def unfollow(user)
    following_ids.delete(user._id)
  end

  def following_count
    following_ids.blank? ? 0 : following_ids.count
  end

  def followers_emails
    following.map(&:email)
  end
end
