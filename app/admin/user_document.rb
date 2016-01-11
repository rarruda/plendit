ActiveAdmin.register UserDocument do

  menu priority: 4
  #actions :index, :show
  actions :index, :show

  #permit_params :user_id, :foobar

  controller do
    defaults finder: :find_by_guid
  end

  index do
    selectable_column
    id_column
    column :user_id
    column :type
    column :category
    column :guid
    column :document
    column :document_file_name
    #column('Document') {|d| image_tag d.document.url }

    column :created_at
    actions
  end

end