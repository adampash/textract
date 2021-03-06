require "textract/version"
require 'mechanize'
require 'nokogiri'
require 'opengraph_parser'
require 'reverse_markdown'
require 'readability'

module Textract
  # attr_accessor :client
  TAG_WHITELIST = %w[
    div span p a img ul ol li blockquote table tr td h1 h2 h3 h4 h5 b em i strong
    figure
  ]

  def self.get_text(url, selectors=nil, format="markdown")
    @client = Client.new(url, selectors, format)
  end

  def self.get_og_tags(html, url)
    begin
      OpenGraph.new(html)
    rescue
      OpenGraph.new(url)
    end
  end

  def self.smart_extract(html, description, selectors)
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
      until els.count < 2 or i > description.split(" ").length
        search_text = description.split(" ")[0..i].join(" ")
        if search_text.index "'"
          els = doc.search "[text()*=\"#{search_text}\"]"
        else
          els = doc.search "[text()*='#{search_text}']"
        end
        i += 1
      end
      if els.count == 1
        el = els[0]
        article_el = el.parent
      else
        article_el = doc
        # do something else if multiple or no matches
      end
    else
      article_el = doc
    end
    Readability::Document.new(article_el.to_s,
                              tags: TAG_WHITELIST,
                              attributes: %w[src href],
                              remove_empty_nodes: false,
                             )
  end

  def self.get_page_title(html)
    Nokogiri::HTML(html).search('head').search('title').text
  end

  def self.get_author(html)
    name_meta = Nokogiri::HTML(html).search('meta[name="author"]')
    if name_meta.empty?
      name_meta = Nokogiri::HTML(html).search('meta[property="author"]')
    end
    name_meta.attribute('content').value unless name_meta.empty?
  end

  def self.get_twitter(html)
    twitter_meta = Nokogiri::HTML(html).search('meta[name="twitter:creator"]')
    if !twitter_meta.empty?
      if !twitter_meta.attribute('content').nil?
        twitter_meta = twitter_meta.attribute('content').value
      elsif !twitter_meta.attribute('value').nil?
        twitter_meta = twitter_meta.attribute('value').value
      else
        twitter_meta = nill
      end
    end
    twitter_meta
  end

  def self.build_site(url, html)
    site_twitter = Nokogiri::HTML(html).search('meta[name="twitter:site"]')
    site_name = Nokogiri::HTML(html).search('meta[property="og:site_name"]')
    if site_name.empty?
      domain_regex = /^(http|ftp)s?:\/\/(([\w\d\-_]+\.)?([\w\d\-_]+)\.(\w+))\//
      site = url.match domain_regex
      site = site[2] unless site[2].nil?
      site_name = site.sub(/^www\./, '').capitalize!
    else
      site_name = site_name.attribute('content').value
    end
    if !site_twitter.empty?
      if !site_twitter.attribute('content').nil?
        site_twitter = site_twitter.attribute('content').value
      elsif !site_twitter.attribute('value').nil?
        site_twitter = site_twitter.attribute('value').value
      else
        site_twitter = nill
      end
    end
    {
      name: site_name,
      twitter: site_twitter,
    }
  end


  def self.build_author(article, html)
    {
      name: article.author || get_author(html),
      twitter: get_twitter(html),
    }
  end

  def self.generate_hash(text)
    Digest::MD5.hexdigest text
  end

  class Client
    attr_reader :html
    attr_reader :url
    attr_reader :tags
    attr_reader :title
    attr_reader :text
    attr_reader :md5
    attr_reader :author
    attr_reader :site

    def initialize(url, selectors, format)
      @url = url
      agent = Mechanize.new
      agent.user_agent_alias = 'Mac Safari'
      @html = agent.get(url).content
      @tags = Textract.get_og_tags(@html, url)
      if @tags.url.match(/^(http|ftp)s?:\/\//)
        @url = @tags.url
      end

      @article = Textract.smart_extract(@html, @tags.description, selectors)
      if @article.content.nil?
        @text = ""
      else
        if format == 'markdown'
          @text = ReverseMarkdown.convert @article.content, unknown_tags: :bypass
        else
          @text = @article.content
        end
      end
      @md5 = Textract.generate_hash @text
      @author = Textract.build_author @article, @html
      @site = Textract.build_site @url, @html
      @title = @tags.title || Textract.get_page_title(@html)
      if @url.match(/\/robots.txt$/) and @title = @text
        @title = @url
      end
    end

    def as_json
      to_h.to_json
    end

    def to_h
      {
        url: @url,
        text: @text,
        md5: @md5,
        author: @author,
        title: @title,
        site: @site,
      }
    end
  end
end
