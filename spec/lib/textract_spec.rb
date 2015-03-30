require_relative '../../lib/textract'
describe Textract do
  it "initializes with the get_text method" do
    url = "http://www.tedcruz.org/about/"
    article = Textract.get_text(url)
    expect(article).to be_a_kind_of Textract::Client
  end

  it "returns article text based on article tag" do
    url = "http://gawker.com/1694508525"
    article = Textract.get_text(url)
    expect(article.text[0..5]).to eq "Import"
    expect(article.md5).to eq "ae57104339fbd6455a91f8ebdc94b90c"
    expect(article.author).to eq "Hamilton Nolan"
  end

  it "returns article text based on opengraph description" do
    url = "http://www.tedcruz.org/record/our-standard-the-constitution/"
    article = Textract.get_text(url)
    expect(article.text[0..5]).to eq "Ted Cr"
  end

  it "can find a twitter profile given a selector" do
    url = "https://twitter.com/lifehacker"
    article = Textract.get_text(url, 'p.ProfileHeaderCard-bio.u-dir')
    expect(article.text.strip).to eq "Don't live to geek; geek to live."
    expect(article.title).to eq "Lifehacker (@lifehacker) | Twitter"
  end

  it "gets the page title from the title tag" do
    html = "<html><head><title>Stuff</title></head><body><h1>FOO!</h1></body></html>"
    expect(Textract.get_page_title(html)).to eq "Stuff"
  end

  it "gets the author from the meta name tag" do
    html = '<html><head><meta name="author" content="Adam Pash"></head><body><h1>FOO!</h1></body></html>'
    expect(Textract.get_author(html)).to eq "Adam Pash"
  end

end
