module Admin
  module Statistic
    class BaseController < ::Admin::BaseController

      private

      def set_dynamic_charts(records, x_axis, date_format, chart_title, args = {} )
        x = records.map {|k| {'label'=> k.send(x_axis).to_formatted_s(date_format) }}

        dataset = {}
        args.each do |key, value|
          dataset[key] = records.map {|k| {'value'=> k.send(value).to_s }}
        end

        new_dataset, new_x = new_data_set(records , args , x_axis)
        return Fusioncharts::Chart.new({
                                           :height => 400,
                                           :width => '100%',
                                           :id => 'chart',
                                           :type => 'MSColumn2D',
                                           :renderAt => 'chart-container',
                                           :dataSource => fetch_data_set(chart_title, new_x, new_dataset)
                                       })
      end

      def fetch_data_set(title, x_axis, y_axis = {})
        {
            'chart' => {
                "caption" => title,
                "subcaption"=> x_axis.empty? ? 'Nothing ' : "#{x_axis[x_axis.length - 1]['label']} To #{x_axis[0]['label']}",
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
            "categories" => [{ "category" => x_axis }],
            "dataset" => data_sets(y_axis)
        }
      end

      def data_sets(y_axis = {})
        arr = []
        y_axis.each do |key, val|
          key = (key == :price ? 'Amount' : key)
          arr.push({ "seriesname" => key, "data" => val })
        end
        arr
      end

      def new_data_set(records , args, x_axis)
        new_dataset = {}
        new_records = records.group_by{|x| x[x_axis].to_date()}
        new_x = new_records.keys.map{|x| {'label' => x} }
        volume_name  = records.first.class.name == 'OrderBid' ?  :origin_volume : :volume if records.present?
        args.each do |key, value|
          new_dataset[key] = []

          new_records.map do |k ,v|
            if key  == :price
              group_value = v.map{|x| x[:price].to_s.to_d * x[volume_name].to_s.to_d  }
              new_dataset[key] << {'value'=> group_value.sum.to_s }
            else
              group_value = v.map{|x|  x[key].to_s.to_d }
              new_dataset[key] << {'value'=> group_value.sum.to_s }
            end
          end

        end
        [new_dataset, new_x]
      end

    end
  end
end
