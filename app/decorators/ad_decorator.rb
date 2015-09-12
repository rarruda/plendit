class AdDecorator < Draper::Decorator
  delegate_all

  def price
    return nil if object.price.nil?
    ( ( object.price / 100).to_i + ( object.price/100.0  ).modulo(1) )
  end

  def pretty_price
    h.number_to_currency_pretty price
  end

  # primary image for ad
  def hero_image_url
    safe_image_url( :hero )
  end

  # primary image for ad
  def result_image_url
    safe_image_url( :searchresult )
  end

  def display_title
    object.title.blank? ?  "(Ingen tittel)" : object.title
  end

  def display_status
    status_names = {
        draft: "utkast",
        waiting_review: "sendt til godkjenning",
        published: "publisert",
        paused: "pauset",
        stopped: "stoppet",
        suspended: "avslått"
    }
    status_names[status.to_sym]
  end

  def to_param
    [self.id, (object.title || '').parameterize].join('----')[0,64]
  end


  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

end
