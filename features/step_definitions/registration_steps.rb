# encoding: utf-8
Когато 'попълня данните на регистрирания студент' do
  fill_in 'Display name', :with => 'Петър Иванов Петров'
  fill_in 'Email', :with => 'pesho@example.org'
end

Когато 'въведа парола' do
  fill_in 'Password', :with => 'foo1234'
  fill_in 'Password confirmation', :with => 'foo1234'
end

То 'трябва да съм успешно влязъл в системата' do
  visit root_path
  page.should have_content('Welcome, Петър Иванов Петров')
end
