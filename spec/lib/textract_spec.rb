require_relative '../../lib/textract'
describe Textract do
  it "initializes with the get_text method" do
    url = "http://www.tedcruz.org/about/"
    textract = Textract.get_text(url)
    expect(textract).to be_a_kind_of Textract::Client
  end

  it "returns article text based on opengraph tags" do
    url = "http://gawker.com/there-are-no-candidates-for-the-middle-class-1694508525"
    textract = Textract.get_text(url)

  end

  context "Client" do

  end
end
