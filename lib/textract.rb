require "textract/version"
require 'httparty'
require 'nokogiri'
require 'opengraph_parser'
require 'reverse_markdown'

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
    article = doc.search('article')
    if article.count == 1
      article_el = article[0]
      # article_el.search('header').remove
    else
      els = [1,2,3]
      i = 1
      until els.count < 2
        search_text = description.split(" ")[0..i].join(" ")
        puts search_text
        els = doc.search "[text()*='#{search_text}']"
        i += 1
      end
      if els.count == 1
        el = els[0]
        article_el = el.parent
      else
        # do something else if multiple or no matches
      end
    end
    markdown = ReverseMarkdown.convert article_el, unknown_tags: :bypass # TODO change to drop once article is supported by reversemarkdown
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
        @title = @tags.title
        require 'pry'; binding.pry
      end
    end
  end
end
