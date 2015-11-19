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
end

