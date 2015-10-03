module SocialButtonsHelper

  @@networks = {
    facebook: {
      name: 'Facebook',
      img: 'logos/fb-45x45.png',
      id: 'fb',
    },
    google: {
      name: 'Google',
      img: 'logos/google-45x45.png',
      id: 'google',
    },
    spid: {
      name: 'SPiD',
      img: 'logos/spid-45x45.png',
      id: 'spid',
    }
  }

  def social_button(network, text)
    network = @@networks[network]
    text = text || "Logg inn med #{network[:name]}"
    render 'shared/social_button.html', text: text, network: network
  end
end
