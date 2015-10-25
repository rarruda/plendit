module SocialButtonsHelper

  @@networks = {
    facebook: {
      name: 'Facebook',
      #icon: 'facebook',
      icon: 'facebook',
      id:   'fb',
    },
    google: {
      name: 'Google',
      #icon: 'google',
      icon: 'google',
      id:   'google',
    },
    spid: {
      name: 'SPiD',
      img:  'logos/spid-45x45.png',
      id:   'spid',
    }
  }

  def social_button(network, text)
    network = @@networks[network]
    text = text || "Logg inn med #{network[:name]}"
    render 'shared/social_button.html', text: text, network: network
  end
end
