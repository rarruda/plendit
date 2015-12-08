class CustomDeviseMailer < Devise::Mailer   
  default template_path: 'devise/mailer' 
  layout 'mailer'

  before_action :add_logo_attachment

  private
  def add_logo_attachment
    attachments.inline['logo.png'] = File.read('public/images/plendit_mail_logo.png')
  end

end
