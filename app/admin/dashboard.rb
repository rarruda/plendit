ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }


#ActiveAdmin::Dashboards.build do
  content title: "Welcome to the Admin control center" do
    div class: "blank_slate_container", id: "dashboard_default_message" do
      panel "Ads waiting_review" do
        table_for Ad.waiting_review do |t|
            #t.column selectable_column
            #t.id_column
            t.column("Status") { |a| status_tag a.status }
            t.column("Title")  { |a| link_to a.title, admin_ad_path(a) }
            t.column("See Listing") { |a| link_to a.title, ad_path(a) }

#      t.column("Assigned To") { |task| task.admin_user.email }
#      t.column("Due Date") { |task| task.due_date? ? l(task.due_date, :format => :long) : '-' }
        end
      end
      panel "UserDocuments waiting_review" do
        #table_for Ad.waiting_review do |t|
        #end
      end
    end
  end

#  section "Tasks that are late" do
#    table_for current_admin_user.tasks.where('due_date < ?', Time.now) do |t|
#      t.column("Status") { |task| status_tag (task.is_done ? "Done" : "Pending"), (task.is_done ? :ok : :error) }
#      t.column("Title") { |task| link_to task.title, admin_task_path(task) }
#      t.column("Assigned To") { |task| task.admin_user.email }
#      t.column("Due Date") { |task| task.due_date? ? l(task.due_date, :format => :long) : '-' }
#    end
#  end
end



#  content title: proc{ I18n.t("active_admin.dashboard") } do
#    div class: "blank_slate_container", id: "dashboard_default_message" do
#      span class: "blank_slate" do
#        #span I18n.t("active_admin.dashboard_welcome.welcome")
#        #small I18n.t("active_admin.dashboard_welcome.call_to_action")
#        panel "Recent Posts" do
#          ul do
#            Ad.waiting_review.map do |a|
#              li link_to(a.title, admin_ad_path(a))
#            end
#          end
#        end
#      end
#    end

    # Here is an example of a simple dashboard with columns and panels.
    #
    # columns do
    #   column do
    #     panel "Recent Posts" do
    #       ul do
    #         Post.recent(5).map do |post|
    #           li link_to(post.title, admin_post_path(post))
    #         end
    #       end
    #     end
    #   end

    #   column do
    #     panel "Info" do
    #       para "Welcome to ActiveAdmin."
    #     end
    #   end
    # end
#  end # content
#end
