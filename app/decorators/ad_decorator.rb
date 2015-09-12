class AdDecorator < Draper::Decorator
  delegate_all

  def price
    return nil if object.price.nil?
    ( ( object.price / 100).to_i + ( object.price/100.0  ).modulo(1) )
  end

  # primary image for ad
  def hero_image_url
    safe_image_url( :hero )
  end

  def title
    object.title.blank? ?  "(Ingen tittel)" : object.title
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
