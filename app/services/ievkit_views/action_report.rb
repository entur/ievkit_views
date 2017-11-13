module IevkitViews
  class ActionReport < Report

    def progression
      progression = @report['progression']
      return {} unless progression
      index_current_step = progression['current_step'].to_i - 1
      @datas = {
        current_step: progression['current_step'].to_i,
        steps_count: progression['steps_count'].to_i,
        current_step_realized: progression['steps'][index_current_step]['realized'].to_i,
        current_step_total: progression['steps'][index_current_step]['total'].to_i
      }.tap{ |hash|
        hash[:steps_percent] = hash[:current_step].percent_of(hash[:steps_count]).round(2)
        hash[:current_step_percent] = hash[:current_step_realized].percent_of(hash[:current_step_total]).round(2)
      }
    end

    def files
      datas = []
      return datas unless @report['files']
      @report['files'].each do |d|
        next unless d['name']
        datas << {
          name: d['name'],
          type: d['type'],
          status: d['status']&.downcase&.to_sym,
          count_error: d['check_point_error_count'].to_i,
          count_warning: d['check_point_warning_count'].to_i,
          count_info: d['check_point_info_count'].to_i,
          check_point_errors: d['check_point_errors']
        }.tap{ |hash|
          hash[:error_or_warning] = (hash[:count_error] + hash[:count_warning] + hash[:count_info]) > 0
        }
      end
      return sort_datas(datas)
      #search_for(datas)
    end

    def objects(type = nil)
      datas = []
      return datas unless @report['objects']
      @report['objects'].each do |d|
        next unless d['type']
        next if type && type != d['type']
        datas << {
          name: d['type'] != 'line' ? I18n.t("report.default_view.#{d['type']}") : d['description'],
          type: d['type'],
          status: d['status']&.downcase&.to_sym,
          count_error: d['check_point_error_count'].to_i,
          count_warning: d['check_point_warning_count'].to_i,
          count_info: d['check_point_info_count'].to_i,
          check_point_errors: d['check_point_errors']
        }.tap{ |hash|
          hash[:error_or_warning] = (hash[:count_error] + hash[:count_warning] + hash[:count_info]) > 0
        }
      end
      return sort_datas(datas)
      # search_for(datas)
    end

    def collections(type = 'line')
      datas = []
      return datas unless @report['collections'].present?
      collections = []
      @report['collections'].each{ |el|
        collections << el['objects'] if el['type'] == type
      }
      collections.flatten!
      return datas unless collections.count > 0
      collections.each do |d|
        next unless d['description']
        datas << {
          name: d['type'] != 'line' ? I18n.t("report.default_view.#{d['type']}") : d['description'],
          type: d['type'],
          status: d['status']&.downcase&.to_sym,
          count_error: d['check_point_error_count'].to_i,
          count_warning: d['check_point_warning_count'].to_i,
          count_info: d['check_point_info_count'].to_i,
          check_point_errors: d['check_point_errors']
        }.tap{ |hash|
          hash[:error_or_warning] = (hash[:count_error] + hash[:count_warning] + hash[:count_info]) > 0
        }
      end
      return sort_datas(datas)
      # search_for(datas)
    end
  end
end
