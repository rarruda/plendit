module AvatarHelper

  def plendbot_avatar(size)
    image_tag 'plendbot/robot_profile_01.png', alt: '', class: "avatar--#{size}", size: size
  end

  # todo: add a helper for regular avatar as well

end