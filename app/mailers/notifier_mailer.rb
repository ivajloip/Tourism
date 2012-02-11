class NotifierMailer < ActionMailer::Base
  default from: "Support <project.31222.80307@gmail.com>", :reply_to => '"Project" project.31222.80307@gmail.com'

  def new_comment(comment)
    @article_title = comment.article.title
    @commenter_name = comment.author_name
    @comment_body = comment.content
    @article_url = article_url(comment.article)

    mail :to => comment.article.followers_emails,
         :subject => "#{I18n.t('comment.added.subject', article_title: @article_title)}"
  end

  def article_edited(article)
    @article_title = article.title
    @author_name = article.author_name
    @article_body = article.content
    @article_url = article_url(article)

    mail :to => article.followers_emails,
         :subject => "#{I18n.t('article.edited.subject', article_title: @article_title)}"
  end

  def article_added(user, article)
    @article_title = article.title
    @author_name = article.author_name
    @article_body = article.content
    @article_url = article_url(article)

    mail :to => user.try(:followers_emails),
         :subject => "#{I18n.t('article.added.subject', :article_title => @article_title)}"
  end
end
