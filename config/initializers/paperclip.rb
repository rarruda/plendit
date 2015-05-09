


# Allow interpolation of :ad_id
Paperclip.interpolates :ad_id do |attachment, style|
  attachment.instance.ad_id
end

