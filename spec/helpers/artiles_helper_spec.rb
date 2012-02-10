require 'spec_helper'

describe ArticlesHelper do
  describe "(content @article)" do
    it "escapes html tags" do
      article = build(:article, content: "asf \n <p class='asd'>fda</p>") 
      content(article).should eq "asf \n &lt;p class='asd'&gt;fda&lt;/p&gt;"
    end

    it "converts image markup into img tag" do
      article = build(:article, content: "[foo][text](http://link.com/fdas.jpg)")
      content(article).should eq "[foo]<img src=\"http://link.com/fdas.jpg\" alt=\"text\" />"
    end

    it "converts image text even when whitespace present" do
      article = build(:article, content: "[far bar](foobar)")
      content(article).should eq "<img src=\"foobar\" alt=\"far bar\" />"
    end

    it "does not convert brokern image - text containing new lines" do
      article = build(:article, content: "[far\nbar](foobar)")
      content(article).should eq "[far\nbar](foobar)"
    end

    it "does not convert broker image url markup into img tag" do
      article = build(:article, content: "[farbar](foo\nbar)")
      content(article).should eq "[farbar](foo\nbar)"
    end

    it "does not keep dangerous image url" do
      article = build(:article, content: "[<script>](<script>)")
      content(article).should eq '<img src="&lt;script&gt;" alt="&lt;script&gt;" />'
    end
  end
end
