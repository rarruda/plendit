module AvatarHelper

  def plendbot_avatar(size)
    image_tag 'plendbot/robot_profile_01.png', alt: '', class: "avatar--#{size}", size: size
  end

  def avatar_image(user, size, options = {})
    sizes = {
      huge:   '120x120',
      large:  '80x80',
      medium: '64x64',
      small:  '48x48',
      tiny:   '24x24'
    }

    css_class = "avatar avatar--#{size} #{options[:class]}"
    image_tag user.safe_avatar_url, alt: '', class: css_class, size: sizes[size]
  end

end