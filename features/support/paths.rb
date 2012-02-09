# encoding: utf-8
module NavigationHelpers
  def path_to(page_name)
    case page_name
      when /страницата за "Sign up"/
        new_user_registration_path
      else
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(NavigationHelpers)
