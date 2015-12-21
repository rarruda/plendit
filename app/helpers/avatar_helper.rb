module AvatarHelper

  def plendbot_avatar(size, options = {})
    image_tag 'plendbot/robot_profile_01.png', alt: '', class: "avatar--#{size} #{options[:class]}", size: size
  end

  def avatar_image(user, size, options = {})
    avatar_image_from_url user.safe_avatar_url, size, options
  end

  def avatar_image_from_url(url, size, options = {})
    sizes = {
      huge:   '120x120',
      large:  '80x80',
      medium: '64x64',
      small:  '48x48',
      tiny:   '24x24'
    }

    css_class = "avatar avatar--#{size} #{options[:class]}"
    image_tag url, alt: '', class: css_class, size: sizes[size]
  end

  def stars rating, size, rating_count = nil
    case size
    when :medium
      class_name = "rating-stars__star"
      img_size = "22x22"
    when :small
      class_name = "rating-stars__star--small"
      img_size = "14x14"
    when :tiny
      class_name = "rating-stars__star--tiny"
      img_size = "12x12"
    end

    if rating > 5 or rating < 0
      puts "out of bounds"
      rating = 5 if rating > 5
      rating = 0 if rating < 0
    end

    remainder_star = rating - rating.floor
    full_stars  = rating.floor
    part_stars  = ( remainder_star > 0.1 and remainder_star < 0.9 ) ? 1 : 0
    empty_stars = ( 5 - ( full_stars + part_stars ) )

    tags = []

    full_stars.times do
      tags << image_tag("star_full.svg", size: img_size, alt: "", class: class_name)
    end

    if part_stars == 1
      tags << image_tag("star_half.svg", size: img_size, alt: "", class: class_name)
    end

    empty_stars.times do
      tags << image_tag("star_empty.svg", size: img_size, alt: "", class: class_name )
    end

    unless rating_count.nil?
      tags << content_tag(:span, " (#{rating_count})")
    end

    tags.join.html_safe
  end

end
