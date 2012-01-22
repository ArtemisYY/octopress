# coding: utf-8

require 'rubygems'
require 'hpricot'
require 'fileutils'
require 'time'
require 'ya2yaml'
require File.join(File.dirname(__FILE__), "downmark_it")
require 'nokogiri'
require 'cgi'

LANG_TABLE = {
  'asm' => 'nasm',
  'lisp' => 'cl',
}

def filter_html(html)
  def remove_node(node)
    node.children.each do |child|
      node.add_previous_sibling child
    end
    node.remove
  end

  def underline_to_u(doc, node)
    u = doc.create_element 'u'
    node.children.each do |child|
      u << child
    end
    node.add_previous_sibling u
    node.remove
  end

  def pre_to_codeblock(doc, node)
    lang = node['class'][/brush: (\w+)/, 1] rescue ''
    lang = LANG_TABLE[lang] if LANG_TABLE.include? lang
    u = doc.create_text_node "\n\n``` #{lang}\n#{node.text}\n```\n\n"
    node.add_previous_sibling u
    node.remove
  end

  html.sub!(/<\!--more--!>/, '')
  doc = Nokogiri::HTML html
  doc.css('p').each do |p|
    remove_node p
  end

  doc.css('span').each do |span|
    remove_node(span) if span['style'] and span['style'][/font-family/]
    underline_to_u(doc, span) if span['style'] and span['style'][/underline/]
  end

  doc.css('pre').each do |pre|
    pre_to_codeblock(doc, pre) if pre['class'] and pre['class'][/brush/]
  end
  CGI.unescapeHTML(doc.css('body').inner_html)
end

module Jekyll
  # This importer takes a wordpress.xml file, which can be exported from your
  # wordpress.com blog (/wp-admin/export.php).
  module WordpressDotCom
    def self.process(filename = "wordpress.xml")
      import_count = Hash.new(0)
      doc = Hpricot::XML(File.read(filename))

      (doc/:channel/:item).each do |item|
        title = item.at(:title).inner_text.strip
        permalink_title = item.at('wp:post_name').inner_text
        # Fallback to "prettified" title if post_name is empty (can happen)
        if permalink_title == ""
          permalink_title = title.downcase.split.join('-')
        end

        date = Time.parse(item.at('wp:post_date').inner_text)
        status = item.at('wp:status').inner_text

        if status == "publish"
          published = true
        else
          published = false
        end

        type = item.at('wp:post_type').inner_text
        tags = (item/:category).select{|c| c['domain'] == 'post_tag'}.map{|c| c.inner_text}.reject{|c| c == 'Uncategorized'}.uniq
        categories = (item/:category).select{|c| c['domain'] == 'category'}.map{|c| c.inner_text}.reject{|c| c == 'Uncategorized'}.uniq
        excerpt = item.at('excerpt:encoded').inner_text

        name = "#{date.strftime('%Y-%m-%d')}-#{permalink_title}.md"
        header = {
          'layout'     => type,
          'title'      => title,
          'tags'       => tags,
          'categories' => categories,
          'status'     => status,
          'type'       => type,
          'published'  => published,
          'excerpt'    => excerpt,
          'comments'   => true,
        }.delete_if {|k,v| v.nil? || v == ''}

        FileUtils.mkdir_p "_#{type}s"
        File.open("_#{type}s/#{name}", "w:utf-8") do |f|
          f.puts header.ya2yaml
          f.puts '---'
          f.puts filter_html(item.at('content:encoded').inner_text)
        end

        import_count[type] += 1
      end

      import_count.each do |key, value|
        puts "Imported #{value} #{key}s"
      end
    end
  end
end

Jekyll::WordpressDotCom.process(ARGV[0])
