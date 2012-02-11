require "spec_helper"

describe NotifierMailer do
  describe "new comment" do
    subject { NotifierMailer.new_comment(comment) }

    let(:comment) { double 'comment' }
    let(:article) { build_stubbed :article }

    before do
      comment.stub article: article
      article.stub :followers_emails => ['follower@example.org']
      comment.stub content: 'Comment body'
      comment.stub author_name: 'Comment author'
    end

    it { should have_subject "There is new comment on Title" }
    it { should deliver_to 'follower@example.org' }
    it { should have_body_text 'Comment author' }
    it { should have_body_text article_url(article) }
    it { should have_body_text 'Comment body' }
  end

  describe "article edited" do
    subject { NotifierMailer.article_edited(article) }

    let(:article) { double :article }

    before do
      article.stub title: 'Title'
      article.stub :followers_emails => ['follower@example.org']
      article.stub content: 'Article body'
      article.stub author_name: 'Article author'
    end

    it { should have_subject "Title was modified" }
    it { should deliver_to 'follower@example.org' }
    it { should have_body_text 'Article author' }
    it { should have_body_text article_url(article) }
    it { should have_body_text 'Article body' }
  end

  describe "article added" do
    subject { NotifierMailer.article_added(user, article) }

    let(:article) { double :article }
    let(:user) { double :user }

    before do
      article.stub title: 'Title'
      article.stub content: 'Article body'
      article.stub author_name: 'Article author'
      user.stub followers_emails: ['follower@example.org']
    end

    it { should have_subject "Title was created" }
    it { should deliver_to 'follower@example.org' }
    it { should have_body_text 'Article author' }
    it { should have_body_text article_url(article) }
    it { should have_body_text 'Article body' }
  end
end
