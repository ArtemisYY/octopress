#encoding: UTF-8

require './plugins/post_filters'

module InsertSpaceFilter
  def insert_ch_en_space(input)
    unless @he_regex
      en = '[a-zA-Z0-9]'
      han = '\p{Han}'
      link = '[\[\(][^\]\)]*[\]\)]'
      @he_regex = Regexp.new("(#{han})(#{en})")  # 汉e
      @eh_regex = Regexp.new("(#{en})(#{han})")  # e汉
      @hne_regex = Regexp.new("(#{han})(\\[#{en})")  # 汉[e
      @enh_regex = Regexp.new("(#{en})(\\[#{han})")  # e[汉
      @hle_regex = Regexp.new("(\\[.*?#{han}\\]#{link})(#{en})")  # [...汉](...)e
      @elh_regex = Regexp.new("(\\[.*?#{en}\\]#{link})(#{han})")  # [...e](...)汉
    end
    input.gsub(@he_regex, '\1 \2').
      gsub(@eh_regex, '\1 \2').
      gsub(@hne_regex, '\1 \2').
      gsub(@enh_regex, '\1 \2').
      gsub(@hle_regex, '\1 \2').
      gsub(@elh_regex, '\1 \2')
    
  end
end

module Jekyll           
  class MyFilters < PostFilter
    include InsertSpaceFilter
    def pre_render(post)
      post.content = insert_ch_en_space(post.content)
    end
  end
end

Liquid::Template.register_filter InsertSpaceFilter
