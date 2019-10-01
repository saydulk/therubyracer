module Private
  class IdDocumentsController < BaseController
    before_action :is_verified, only: [:edit, :update]

    def edit
      @id_document = current_user.id_document || current_user.create_id_document
    end

    def update
      @id_document = current_user.id_document

      if @id_document.update_attributes id_document_params
        @id_document.submit! if @id_document.unverified?
        redirect_to settings_path, notice: t('.notice')
      else
        Rails.logger.info " ID Document - email #{@id_document.name} =====> #{@id_document.errors.messages}"
        render 'edit'
      end
    end

    private

    def is_verified
     redirect_to settings_path if current_user.id_document.verified?
    end

    def id_document_params
      params.require(:id_document).permit(:name, :birth_date, :middle_name, :last_name, :gender, :contact_no, :country_code, :address, :city, :country, :zipcode,
                                          :id_document_type, :id_document_number, :id_bill_type,
                                          {id_document_file_attributes: [:id, :file]},
                                          {id_bill_file_attributes: [:id, :file]})
    end
  end
end
