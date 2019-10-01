# require 'active_support/core_ext/module'
class IdDocumentDatatable < AjaxDatatablesRails::ActiveRecord
  extend Forwardable

  def_delegators :@view,
                :admin_id_document_path
                :raw
                :concat

  def view_columns
    # Declare strings in this format: ModelName.column_name
    # or in aliased_join_table.column_name format
    @view_columns ||= {
       name: { source: "IdDocument.name", cond: :like, searchable: true, orderable: true },
       email: { source: "Member.email", cond: :like, searchable: true, orderable: true  },
       # id_document_type: { source: "IdDocument.id_document_type", cond: :like, searchable: true, orderable: false  },
       id_bill_type: { source: "IdDocument.id_bill_type", cond: :like , searchable: true, orderable: false },
       updated_at: { source: "IdDocument.updated_at", cond: :like, searchable: false, orderable: false  },
       verified: { sour1e: "IdDocument.aasm_state", cond: :like, searchable: false, orderable: false  },

    }
  end

  def data
    records.map do |record|
      if record.present?
        {
          name: record.name.to_s.capitalize,
          email: record.member ? record.member.email : '',
          # id_document_type: (record.id_document_type.present? ? record.id_document_type.humanize : '' ),
          id_bill_type: (record.id_bill_type.present? ? record.id_bill_type.humanize : '' ),
          updated_at: record.updated_at,
          verified:  (record.verified? ? ("<span class='label label-success'>YES</span>".html_safe) : ("<span class='label label-danger'>NO</span>".html_safe)),
          view_user: "<a href='/admin/id_documents/#{record.id}'>View</a>".html_safe
        }
      end
    end
  end

  def get_raw_records
    status = params[:verified]== 'yes' ? %w(verified) : %w(unverified verifying)
    records = IdDocument.includes(:member).references(:member).order(created_at: :desc)
    records = records.is_verified(status)
    records = records.where("members.email like ? or id_documents.name like ?", "%#{params[:search][:value].strip}%", "%#{params[:search][:value].strip}%" ) if params[:search][:value].present?
    records
  end
end
