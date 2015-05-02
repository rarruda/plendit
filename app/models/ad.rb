class Ad < ActiveRecord::Base
  belongs_to :user
  has_many :received_feedbacks, :class_name => "Feedback"
  has_many :ad_items
  belongs_to :location


  validates :title, presence: true, length: { in: 3..255 }
  validates :body,  presence: true
  validates :user,  presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  #validates :location, presence: true

  def related_ads_from_user
    self.user.ads.reject { |ad| ad.id == self.id }
  end

  def summary
    # fixme: There are a bunch of ways this can be improved. There might
    # be some gems for it already. For instance, end only at sentence
    # breaks and allow small overflows when close to full length.
    # Also, stick 240 in config somewhere?
    # Also, better whitespace / split / paragraph detection

    first_paragraph = self.body.split("\r\n\r\n").first
    if first_paragraph.size > 240
        first_paragraph[0...240] + "…"
    else
        first_paragraph
    end
  end

end
