class Notifier < ActionMailer::Base
  default from: "Support <project.31222.80307@gmail.com>", :reply_to => '"Project" project.31222.80307@gmail.com'

  def new_comment(comment)
    logger.debug "----Mailing new comment #{comment}-----"
    @article_title = comment.article.title
    @commenter_name = comment.author_name
    @comment_body = comment.content
    @article_url = article_url(comment.article)

    mail :to => comment.article.followers_emails,
         :subject => "#{I18n.t(:new_comment_on, :defaut => 'There is new comment on')} #{@article_title}"
  end

  def article_edited(article)
    @article_title = article.title
    @commenter_name = article.author_name
    @article_body = article.content
    @article_url = article_url(article)

    mail :to => article.followers_emails,
         :subject => "#{@article_title} #{I18n.t(:article_edited, :defaut => 'was modified')}"
  end

#  Hr1si1Iv0:*
end
