module Admin
  module Statistic
    class MembersController < BaseController
      def show
        @members_count = Member.count

        if params.has_key?('date')
          @register_group = Member.where('extract(month  from created_at) = ? AND extract(year  from created_at) = ?', params['date']['month'], params['date']['year']).select('date(created_at) as date, count(id) as total, sum(activated IS TRUE) as total_activated').group('date(created_at)').order('created_at asc')
        else
          @register_group = Member.where('created_at > ?', 30.days.ago).select('date(created_at) as date, count(id) as total, sum(activated IS TRUE) as total_activated').group('date(created_at)').order('created_at asc')
        end
        @chart = set_dynamic_charts(@register_group)
      end

      private

      def set_dynamic_charts(records)
        dates = records.map {|k| {'label'=> k.date.strftime('%Y-%m-%d') }}
        activated = records.map {|k| {'value'=> k.total_activated.to_s }}
        registered = records.map {|k| {'value'=> k.total.to_s }}
        return Fusioncharts::Chart.new({
                                    :height => 400,
                                    :width => '100%',
                                    :id => 'chart',
                                    :type => 'MSColumn2D',
                                    :renderAt => 'chart-container',
                                    :dataSource => fetch_data_set(dates, activated, registered)
                                })
      end

      def fetch_data_set(dates, activated, registered)
        {
            'chart' => {
                "caption" => 'New Registered vs. Activated Users',
                "subcaption"=> "#{dates[0]['label']} To #{dates[dates.length - 1]['label']}",
                "paletteColors" => '#2876DD,#0F283E',
                "decimals" => '0',
                "placevaluesinside" => '0',
                "rotatevalues" => '0',
                "divlinealpha" => '50',
                "plotfillalpha" => '80',
                "drawCrossLine" => '1',
                "crossLineColor" => '#F3F5F6',
                "crossLineAlpha" => '80',
                "toolTipBgColor" => '#ffffff',
                "toolTipColor" => '#000000',
                "theme" => 'fint'
            },
            "categories" => [{
                                 "category" => dates
                             }],
            "dataset" => [{
                              "seriesname" => 'Registered',
                              "data" => registered
                          },
                          {
                              "seriesname" => 'Activated',
                              "data" => activated
                          }
            ]
        }
      end
    end
  end
end
