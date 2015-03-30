require "textract/version"
require 'httparty'
require 'nokogiri'
require 'opengraph_parser'
require 'reverse_markdown'
require 'readability'

module Textract
  # attr_accessor :client

  def self.get_text(url, selectors=nil)
    @client = Client.new(url, selectors)
  end

  def self.get_og_tags(html)
    OpenGraph.new(html)
  end

  def self.get_text_from_description(html, description, selectors)
    doc = Nokogiri::HTML html
    if selectors.nil?
      article = doc.search('article')
    else
      article = doc.search(selectors)
    end
    if article.count == 1
      article_el = article[0]
    elsif !description.nil? and article.count == 0
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
    else
      article_el = doc
    end
    article = Readability::Document.new(article_el.to_s,
                                        tags: %w[div span p a img ul ol li blockquote table tr td h1 h2 h3 h4 h5 b em i strong],
                                        attributes: %w[src href],
                                        remove_empty_nodes: true,
                                       ).content
    markdown = ReverseMarkdown.convert article, unknown_tags: :bypass
    # TODO change to drop once article is supported by reversemarkdown
    markdown
  end

  def self.get_page_title(html)
    title = Nokogiri::HTML(html).search('title')
    require 'pry'; binding.pry
  end

  class Client
    attr_reader :html
    attr_reader :url
    attr_reader :tags
    attr_reader :title
    attr_reader :text

    def initialize(url, selectors)
      @url = url
      @html = HTTParty.get url
      @tags = Textract.get_og_tags(@html)
      if @tags.nil? or @tags.description.nil?
        # use readability method
        @text = Textract.get_text_from_description(@html, nil, selectors)
        @title = Textract.get_page_title(@html)
      else
        @text = Textract.get_text_from_description(@html, @tags.description, selectors)
        @title = @tags.title
      end
    end
  end
end
