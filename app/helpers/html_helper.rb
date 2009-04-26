
module HtmlHelper
  extend ActionView::Helpers

  BB_TAGS = [ [ /\[quote\](.+?)\[\/quote\]/i, '<div class="quote"><div class="quote_text">\1</div></div>' ], 
              [ /\[quote=(.+?)\](.+?)\[\/quote\]/i, '<div class="quote">\1 wrote:<br><div class="text">\2</div></div>' ], 
              [ /\[b\](.+?)\[\/b\]/i, '<span class="bold">\1</span>' ],
              [ /\[i\](.+?)\[\/i\]/i, '<span class="italic">\1</span>' ],
              [ /\[u\](.+?)\[\/u\]/i, '<span class="underline">\1</span>' ],
              [ /\[s\](.+?)\[\/s\]/i, '<span class="strike">\1</span>' ],
              [ /\[left\](.+?)\[\/left\]/i, '<div class="left">\1</div>' ],
              [ /\[center\](.+?)\[\/center\]/i, '<div class="center">\1</div>' ],
              [ /\[right\](.+?)\[\/right\]/i, '<div class="right">\1</div>' ],
              [ /\[url=(.+?)\](.+?)\[\/url\]/i, '<a href="\1">\2</a>' ], 
              [ /\[img\](.+?)\[\/img\]/i, '<img src="\1"/>' ],
              [ /\[youtube\]v=(.+?)\[\/youtube\]/i, '<object width="425" height="344"><param name="movie" value="http://www.youtube.com/v/\1"></param><param name="allowFullScreen" value="true"></param><param name="allowscriptaccess" value="always"></param><embed src="http://www.youtube.com/v/\1" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" width="425" height="344"></embed></object>' ],
              [ /\[color=([^;]+?)\](.+?)\[\/color\]/i, '<span style="color: \1;">\2</span>' ],
              [ /\[size=(.+?)\](.+?)\[\/size\]/i, '<font size="\1">\2</font>' ] ]

  EMOTICONS = [ [ /\[em\]smile\[\/em\]/i, image_tag('emoticons/smile.gif', :class => 'emoticon', :alt => ':-)') ],
                [ /\[em\]wink\[\/em\]/i, image_tag('emoticons/wink.gif', :class => 'emoticon', :alt => ';-)') ],
                [ /\[em\]grin\[\/em\]/i, image_tag('emoticons/grin.gif', :class => 'emoticon', :alt => ':-D') ],
                [ /\[em\]cool\[\/em\]/i, image_tag('emoticons/cool.gif', :class => 'emoticon', :alt => '8-)') ],
                [ /\[em\]kiss\[\/em\]/i, image_tag('emoticons/kiss.gif', :class => 'emoticon', :alt => ':-*') ],
                [ /\[em\]confused\[\/em\]/i, image_tag('emoticons/confused.gif', :class => 'emoticon', :alt => ':-o') ],
                [ /\[em\]no_expression\[\/em\]/i, image_tag('emoticons/no_expression.gif', :class => 'emoticon', :alt => ':-|') ],
                [ /\[em\]angry\[\/em\]/i, image_tag('emoticons/angry.gif', :class => 'emoticon', :alt => '>:-(') ],
                [ /\[em\]sad\[\/em\]/i, image_tag('emoticons/sad.gif', :class => 'emoticon', :alt => ':-(') ],
                [ /\[em\]cry\[\/em\]/i, image_tag('emoticons/cry.gif', :class => 'emoticon', :alt => ':,-(') ] ]

  
  def self.to_html(s)
    if s
      s = s.dup
      parse_line_breaks s, false
      parse_bbcode s, false
      parse_emoticons s, false
    end
  end
  
  def self.parse_line_breaks(s, dup = true)
    if s
      s = s.dup if dup
      s.gsub! "\r\n", '<br>'
      s.gsub! "\n", '<br>'
      s
    end
  end

  def self.parse_bbcode(s, dup = true)
    if s
      s = s.dup if dup
      BB_TAGS.each {|e| s.gsub! e[0], e[1] }
      s
    end
  end
  
  def self.parse_emoticons(s, dup = true)
    if s
      s = s.dup if dup
      EMOTICONS.each {|e| s.gsub! e[0], e[1] }
      s
    end
  end
  
  def self.escape_javascript(s)
    if s
      s = s.dup
      s.gsub!(/\r\n|\n|\r/, "\\n")
      s.gsub(/["']/) {|m| "\\#{m}" }
    end
  end

  def self.sanitize(value)
    RailsSanitize.white_list_sanitizer.sanitize value
  end
end

  
        











