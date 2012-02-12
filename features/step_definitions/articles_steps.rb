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
      :active => true
    }

    Factory(:article, attributes)
  end
end

Дадено 'има околия' do
  Factory(:province, key: 'sofia')
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
