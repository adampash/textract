require "textract/version"
require 'httparty'
require 'nokogiri'
require 'opengraph_parser'

module Textract
  # attr_accessor :client

  def self.get_text(url)
    @client = Client.new(url)
  end

  def self.get_og_tags(html)
    OpenGraph.new(html)
  end

  def self.get_text_from_description(html, description)
    doc = Nokogiri::HTML html
    if description.split(" ").count > 20
      search_text = description[10...20]
    else
      search_text = description
    end
    els = doc.search "[text()*='#{description[5...15]}']"
    if els.count == 1
      el = els[0]
    else
      # do something else if multiple matches
    end
    parent = el.parent
    require 'pry'; binding.pry
  end

  class Client
    attr_reader :html
    attr_reader :url
    attr_reader :tags
    attr_reader :text

    def initialize(url)
      @url = url
      @html = HTTParty.get url
      @tags = Textract.get_og_tags(@html)
      if @tags.description.nil?
        # use readability method
      else
        @text = Textract.get_text_from_description(@html, @tags.description)
      end
    end
  end
end
