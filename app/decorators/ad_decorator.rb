class AdDecorator < Draper::Decorator
  delegate_all
  decorates_association :user
  decorates_association :received_feedbacks


  def price
    # https://github.com/drapergem/draper/issues/523 (on draper 1.4)
    Draper::ViewContext.current.class_eval do
      include ApplicationHelper # workaround for draper test bug
    end

    return nil if object.price.nil?
    h.integer_to_decimal( object.price )
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
    object.title.blank? ?  "Tittel mangler" : object.title
  end

  def display_status
    status_names = {
        draft: "utkast",
        waiting_review: "sendt til godkjenning",
        published: "publisert",
        paused: "pauset",
        stopped: "stoppet",
        refused: "ikke godkjent",
        suspended: "avslått",
    }
    status_names[status.to_sym]
  end

  def summary
    truncate self.body, length: 240
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
