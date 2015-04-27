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
      expect(article.md5).to eq "c11a810a3e73f24aac78fd3e39e69f87"
      expect(article.author).to eq "Hamilton Nolan"
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

end
