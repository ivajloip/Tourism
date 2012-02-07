FactoryGirl.define do
  sequence(:email) { |n| "person-#{n}@mydomain.org" }
  sequence(:article_title) { |n| "Article #{n}" }

  factory :comment do
    author
    article
    content 'Body'
  end

  factory :user, :aliases => [:author] do
    email 
    display_name 'Nemo Nemov'
    password 'password'
  end

  factory :article do
    content 'Body'
    author
    title 'Title'
    province
  end

  factory :province do
    key 'province'
  end

  factory :tag do
    key 'tag'
  end

  factory :admin, parent: :user do
    admin true
  end
end  
