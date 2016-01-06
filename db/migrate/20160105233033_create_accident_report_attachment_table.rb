class CreateAccidentReportAttachmentTable < ActiveRecord::Migration
  def change
    create_table :accident_report_attachments do |t|
      t.references :accident_report, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
