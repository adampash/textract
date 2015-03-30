require_relative '../../lib/textract'
describe Textract do
  it "initializes with the get_text method" do
    url = "http://www.tedcruz.org/about/"
    textract = Textract.get_text(url)
    expect(textract).to be_a_kind_of Textract::Client
  end

  it "returns article text based on article tag" do
    url = "http://gawker.com/1694508525"
    textract = Textract.get_text(url)
    expect(textract.text[0..5]).to eq "Import"
  end

  it "returns article text based on opengraph description" do
    url = "http://www.tedcruz.org/record/our-standard-the-constitution/"
    textract = Textract.get_text(url)
    puts textract.text
    expect(textract.text[0..5]).to eq "Ted Cr"
  end

  it "can find a twitter profile given a selector" do
    url = "https://twitter.com/lifehacker"
    textract = Textract.get_text(url, 'p.ProfileHeaderCard-bio.u-dir')
    expect(textract.text.strip).to eq "Don't live to geek; geek to live."
    expect(textract.title).to eq "Lifehacker (@lifehacker) | Twitter"
  end

end
