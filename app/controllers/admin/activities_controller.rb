module Admin
  class ActivitiesController < BaseController
    skip_load_and_authorize_resource

    before_action :set_member_activity, only: [:csv_activity]
    before_action :set_show_activities, only: [:show_activities, :single_activity_download]

    def index_activity
      respond_to do |format|
        format.html
        format.json { render json: ActivityDatatable.new(params) }
      end
    end

    def show_activities
      # @member_activities = @member_activities.page params[:page]
      respond_to do |format|
        format.html
        format.json { render json: AdminActivityDatatable.new(params) }
      end
    end

    def csv_activity
      fname = 'member_activity'
      send_data Activity.export(@records_array),
                :type => 'text/csv; charset=iso-8859-1; header=present',
                :disposition => "attachment; filename=#{fname}.csv"
    end

    def single_activity_download
      fname = 'single_activity'
      send_data Activity.export_single_activity(@member_activities),
                :type => 'text/csv; charset=iso-8859-1; header=present',
                :disposition => "attachment; filename=#{fname}.csv"
    end

    private

    def set_member_activity
      sql = "SELECT max(t1.`id`) as `id`, max(t1.`created_at`) as `created`, t1.`member_id` , max(t1.`ip_address`) as `ip_address` ,t2.`email` FROM `activities` as t1 INNER JOIN `members` as t2 ON t1.`member_id` = t2.`id`  group by t1.`member_id`"
      @records_array = ActiveRecord::Base.connection.execute(sql)
    end

    def set_show_activities
      @member_id = params[:id]
      @member_activities = Activity.all.where(member_id: @member_id)
    end

  end
end