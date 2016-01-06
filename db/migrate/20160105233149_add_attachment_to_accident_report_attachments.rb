class AddAttachmentToAccidentReportAttachments < ActiveRecord::Migration
  def self.up
    change_table :accident_report_attachments do |t|
      #t.references :accident_reports, index: true #, foreign_key: true
      t.attachment :attachment
    end
  end

  def self.down
    remove_attachment :accident_report_attachments, :attachment
    #remove_reference :accident_report_attachments, :accident_report
  end
end
