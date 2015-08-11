ActiveAdmin.register User do


  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # permit_params :list, :of, :attributes, :on, :model
  #
  # or
  #
  # permit_params do
  #   permitted = [:permitted, :attributes]
  #   permitted << :other if resource.something?
  #   permitted
  # end

  menu :priority => 2
  #actions :index, :show

  permit_params :name, :email, :phone_number, :status, :ephemeral_answer_percent, :avatar_url
    ##, :password

  filter :name
  filter :email
  filter :phone_number
  filter :created_at

#  scope :all, :default => true
#  scope :in_progress
#  scope :complete

  index do
    selectable_column
    id_column
    column :name
    column :email

    column("User Status") {|user| status_tag( user.status ) }
    column(:id) {|u| link_to "Log in as", admin_switch_user_path( scope_identifier: "user_#{u.id}" ) }

    column :created_at
    actions
  end

#  show do
#    panel "Ads" do
#      table_for(user.ads) do |t|
#        t.column("Title") {|ad| auto_link ad.title        }
#        t.column("Price") {|ad| number_to_currency ad.price }
#        #tr :class => "odd" do
#        #  td "Total:", :style => "text-align: right;"
#        #  td number_to_currency(ad.price)
#        #end
#      end
#    end
#
#
#    panel "Feedbacks" do
#      table_for(user.received_feedbacks) do |t|
#        t.column("From User") {|f| auto_link f.from_user.name  }
#        t.column :score
#        t.column("Ad Title") {|f| f.ad.title }
#        t.column :body #("Body") {|f| f.score }
#      end
#    end
#
#    #panel "ad_items" do
#    #  table_for(user.ad_items) do |t|
#    #    t.column("Ad ID")    {|a| auto_link a.ad.id  }
#    #    t.column("Ad Title") {|a| a.ad.title }
#    #    #t.column("AdItem ID") {|a| a.ad_item.id }
#    #  end
#    #end
#
#    panel "Received Bookings" do
#      table_for(user.received_feedbacks) do |t|
#        t.column("From User") {|f| auto_link f.from_user.name  }
#        t.column :score
#        t.column("Ad Title") {|f| f.ad.title }
#        t.column :body #("Body") {|f| f.score }
#      end
#    end
#  end
#
#
#
#  sidebar "User Details", :only => :show do
#    attributes_table_for user do
#      row :name
#      row :email
#      row :phone
#      row :created_at
#      row('user_status') {|u| status_tag u.status}
#    end
#  end


end
