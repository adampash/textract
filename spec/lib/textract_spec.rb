require 'spec_helper'
require 'textract'

describe Textract do
  it "initializes with the get_text method" do
    VCR.use_cassette("cruz") do
      url = "http://www.tedcruz.org/about/"
      article = Textract.get_text(url)
      expect(article).to be_a_kind_of Textract::Client
    end
  end

  it "returns article text based on article tag" do
    VCR.use_cassette("hamno") do
      url = "http://gawker.com/1694508525"
      article = Textract.get_text(url)
      expect(article.text.include?("Import")).to eq true
      expect(article.md5).to eq "9cc00fcdeb4bc41e0649d0776cbb2157"
      expect(article.author[:name]).to eq "Hamilton Nolan"
    end
  end

  it "also includes images" do
    VCR.use_cassette('imgs') do
      url = "http://gawker.com/1696731611"
      img = "http://i.kinja-img.com/gawker-media/image/upload/s--fWYFlEv6--/c_fit,fl_progressive,q_80,w_636/l3sjlg0ariqomd4ubtl6.jpg"
      article = Textract.get_text(url)
      expect(article.text.include?(img)).to be true
    end
  end

  it "returns the canonical url if available" do
    VCR.use_cassette("hamno") do
      url = "http://gawker.com/1694508525"
      article = Textract.get_text(url)
      expect(article.url).to eq "http://gawker.com/there-are-no-candidates-for-the-middle-class-1694508525"
    end
    VCR.use_cassette("buzzfeed hash") do
      url = "http://www.buzzfeed.com/katenocera/rand-paul-is-on-his-own-this-time#.sseGm85KG"
      article = Textract.get_text(url)
      expect(article.url).to eq "http://www.buzzfeed.com/katenocera/rand-paul-is-on-his-own-this-time"
    end
  end

  it "returns article text based on opengraph description" do
    VCR.use_cassette('og') do
      url = "http://www.tedcruz.org/record/our-standard-the-constitution/"
      article = Textract.get_text(url)
      expect(article.text.include?("Ted Cruz")).to eq true
    end
  end

  it "can find a twitter profile given a selector" do
    VCR.use_cassette('selector') do
      url = "https://twitter.com/lifehacker"
      article = Textract.get_text(url, 'p.ProfileHeaderCard-bio.u-dir')
      expect(article.text.strip).to eq "Don't live to geek; geek to live."
      expect(article.title).to eq "Lifehacker (@lifehacker) | Twitter"
    end
  end

  it "gets the page title from the title tag" do
    html = "<html><head><title>Stuff</title></head><body><h1>FOO!</h1></body></html>"
    expect(Textract.get_page_title(html)).to eq "Stuff"
  end

  it "gets the author from the meta name tag" do
    html = '<html><head><meta name="author" content="Adam Pash"></head><body><h1>FOO!</h1></body></html>'
    expect(Textract.get_author(html)).to eq "Adam Pash"
  end

  it "gets twitter handle from metadata" do
    html = '<html><head><meta name="twitter:creator" content="@adampash"></head><body><h1>FOO!</h1></body></html>'
    expect(Textract.get_twitter(html)).to eq "@adampash"
  end

  it "gets more author detail when possible" do
    VCR.use_cassette('twitter byline') do
      url = "http://www.buzzfeed.com/daviddobbs/weighing-the-promises-of-big-genomics"
      text = Textract.get_text(url)
      expect(text.author[:name]).to eq "David Dobbs"
      expect(text.author[:twitter]).to eq "@david_dobbs"
    end
  end

  it "gets site detail when possible" do
    VCR.use_cassette('bits') do
      url = "http://bits.blogs.nytimes.com/2015/05/21/members-of-congress-ask-for-review-of-dropped-espionage-case/"
      text = Textract.get_text(url)
      expect(text.site[:name]).to eq "Bits Blog"
      expect(text.site[:twitter]).to eq "@nytimesbits"
    end
    VCR.use_cassette('site bug') do
      url = "http://www.nytimes.com/2015/05/22/us/politics/obamas-twitter-debut-potus-attracts-hate-filled-posts.html"
      text = Textract.get_text(url)
      expect(text.site[:name]).to eq "Nytimes.com"
      expect(text.site[:twitter]).to eq "@nytimes"
    end
  end

  it "converts itself to json" do
    VCR.use_cassette('json') do
      url = "http://gawker.com/1694508525"
      article = Textract.get_text(url)
      expect(article.to_json).to be_a_kind_of String
    end
  end

  it "handles problem urls" do
    VCR.use_cassette('bad frisky') do
      url = "http://www.thefrisky.com/2015-04-22/10-things-i-was-irrationally-jealous-of-in-high-school-and-admittedly-still-am/"
      article = Textract.get_text(url)
      expect(article.to_json).to be_a_kind_of String
    end
  end

  it "handles other problems" do
    VCR.use_cassette('stackoverflow') do
      url = "http://stackoverflow.com/questions/4698118/google-chrome-extensions-how-to-include-jquery-in-programatically-injected-cont"
      text = Textract.get_text(url)
      expect(text.to_json).to be_a_kind_of String
    end
  end

  it "handles robots.txt files" do
    VCR.use_cassette('robots') do
      url = "http://www.buzzfeed.com/robots.txt"
      text = Textract.get_text(url)
      expect(text.url).to eq url
      expect(text.title).to eq url
    end
  end

end
