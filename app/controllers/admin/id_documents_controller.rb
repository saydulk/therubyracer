module Admin
  class IdDocumentsController < BaseController
    load_and_authorize_resource

    def index
      respond_to do |format|
        format.html
        format.json { render json: IdDocumentDatatable.new(params) }
      end
    end

    def show
    end

    def csv_download
      if params[:type] == 'verified'
        fname = 'verified_account'
        data = @id_documents.is_verified('verified').order('updated_at DESC')
      else
        fname = 'unverified_account'
        data = IdDocument.is_verified(%w(unverified verifying)).order('updated_at DESC')
      end
      send_data IdDocument.export(data),
                :type => 'text/csv; charset=iso-8859-1; header=present',
                :disposition => "attachment; filename=#{fname}.csv"
    end

    def update
      @id_document.approve! if params[:approve]
      @id_document.reject!  if params[:reject]

      redirect_to admin_id_document_path(@id_document)
    end
  end
end
