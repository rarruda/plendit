ActiveAdmin.register Ad do

  menu :priority => 4

  permit_params :user_id, :title, :body, :price, :location_id,:tags,  :status, :category, :insurance_required


  filter :status, as: :select, collection: ->{ Ad.statuses.keys }


  index do
    selectable_column
    id_column
    column("See Ad") { |ad| link_to "#{ad.id}", ad_path( ad.id ) }
    column(:status)   {|ad| status_tag(ad.status) }

    column :title
    column :price
    column :tags

    column("Owner") { |ad| link_to "#{ad.user.safe_first_name}", admin_user_path( ad.user.id ) }
    column :created_at
    actions
  end

  form do |f|
    f.semantic_errors

    f.inputs 'other' do
      f.input :user
      f.input :title
      f.input :body
      f.input :price
      f.input :location, as: :select, collection: Hash[Location.all.map{|l| ["#{l.id} - #{l.address_line} - #{l.post_code}",l.id]}] #show address/etc
      f.input :tags
      f.input :status,   as: :select, collection: Ad.statuses.keys
      f.input :category, as: :select, collection: Ad.categories.keys
      f.input :insurance_required
    end

    f.actions
  end

end
