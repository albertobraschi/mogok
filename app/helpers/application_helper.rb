
module ApplicationHelper

  def page_name(s)
    content_for :title_page_name, "#{APP_CONFIG[:app_name]} : : #{s}"
  end

  def self.process_search_keywords(param, max_keywords = nil)
    unless param.blank?
      keywords = ''
      a = max_keywords ? param.split(' ')[0, max_keywords] : param.split(' ')
      a.each {|s| s.gsub!(/[^\w\-]/, '') } # remove non-alphanumeric chars
      a.uniq!
      a.each {|s| keywords << s << ' ' if s.size >= 4 }
      keywords.strip
    end
  end

  def user_link(u, include_stats = false)
    if u
      html_options = {}
      unless u.active?
        html_options[:class] = "#{u.role.css_class} user_inactive"
        html_options[:title] = t('helper.application_helper.user_link.inactive')
      else
        html_options[:class] = u.role.css_class
        if include_stats
          html_options[:title] = "up: #{textual_data_amount u.uploaded} | down: #{textual_data_amount u.downloaded} | ratio: #{number_to_ratio u.ratio}"
        else
          html_options[:title] = u.role.description
        end
      end
      link_to u.username, users_path(:action => 'show', :id => u), html_options
    end
  end

  def number_to_ratio(n)
    number_with_precision n, I18n.t('number.ratio.format')
  end

  def avatar_image(user)
    url = user.avatar.blank? ? APP_CONFIG[:users][:default_avatar] : user.avatar
    image_tag url, :class => 'avatar', :alt => 'Avatar'
  end

  def country_image(c)
    c ? image_tag(c.image, :class => 'flag', :alt => c.name, :title => c.name) : '-'
  end

  def spinner_image
    image_tag 'spinner.gif', :class => 'spinner'
  end

  def field_error(message)
    message = message[0] if message.is_a? Array
    message.blank? ? nil : "<div class='field_error'>#{message}</div>"
  end

  def textual_time_interval(date, sufix = nil) # very rough
    period = (Time.now.to_i - date.to_i).abs
    if period < 1.minute
      t = period > 0 ? period : 1
      s = t('datetime.textual.seconds', :count => t)
    elsif period < 1.hour
      t = period / 1.minute
      s = t('datetime.textual.minutes', :count => t)
    elsif period < 2.days
      t = period / 1.hour
      s = t('datetime.textual.hours', :count => t)
    elsif period < 1.month
      t = period / 1.day
      s = t('datetime.textual.days', :count => t)
    elsif period < 2.year
      t = period / 1.month
      s = t('datetime.textual.months', :count => t)
    else
      t = period / 1.year
      s = t('datetime.textual.years', :count => t)
    end
    s << ' ' << sufix if sufix
    s
  end

  def textual_data_amount(amount)
    if amount.nil? || amount == 0
      n = 0
    else
      amount = amount.to_i if amount.is_a?(String)
      if amount < 1.kilobytes
        n = amount
        unit = 'B'
      elsif amount < 1.megabytes
        n = amount / 1.kilobytes.to_f
        unit = 'KB'
      elsif amount < 1.gigabytes
        n = amount / 1.megabytes.to_f
        unit = 'MB'
      elsif amount < 1.terabytes
        n = amount / 1.gigabytes.to_f
        unit = 'GB'
      elsif amount < 1.petabytes
        n = amount / 1.terabytes.to_f
        unit = 'TB'
      else
        n = amount / 1.petabytes.to_f
        unit = 'PB'
      end
    end
    "#{number_with_precision n, t('number.data_amount.format')} #{unit}"
  end
end
