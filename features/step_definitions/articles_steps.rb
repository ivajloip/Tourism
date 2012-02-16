# encoding: utf-8
Дадено 'че сме вписани в системата' do
  Factory(:user, email: 'test@example.org')
  visit new_user_session_path
  fill_in 'Email', with: 'test@example.org'
  fill_in 'Password', with: 'password'
  click_button 'Sign in'
end

Дадено 'че има следните статии:' do |table|
  table.hashes.each do |row|
    attributes = {
      :author => Factory(:user, :display_name => row['Автор']),
      :title => row['Заглавие'],
      :content => row['Съдържание'],
      :province => Factory(:province, :key => row['Околия']),
      :active => true,
      :created_at => Time.new(2012, 2, 14)
    }

    Factory(:article, attributes)
  end
end

Дадено 'има околия' do
  Factory(:province, key: 'sofia')
end

Дадено 'има статия' do
  Factory(:article)
end

Когато 'попълня нова статия' do 
  fill_in 'Title', with: 'Test title'
  select 'Sofia', :from => 'Province'
  fill_in 'Content', with: 'Test content'
  click_button 'Create Article'
end

То 'трябва да виждам следните статии:' do |table|
  header = all('table thead tr th').map(&:text)
  rows = all('table tbody tr').map do |table_row|
    table_row.all('td').map(&:text)
  end
  table.diff! [header] + rows
end

То 'трябва да видя новата статия' do
  within '#notice' do
    page.should have_content('Article was successfully created.')
  end
end

То /трябва статията да е харесана "([^"]*)" път(?:и)? и да не е харесана "([^"]*)" път(?:и)?/ do |likes, dislikes|
  within '#votes' do
    page.should have_content("#{likes} Liking, #{dislikes} Disliking")
  end
end

То 'трябва да има коментар с тяло "$body"' do |body|
  article = Article.where(:title => 'Title')
  article.exists?.should be_true
  article.first.comments.map(&:content).should include(body)
end
