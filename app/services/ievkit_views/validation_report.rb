module IevkitViews
  class ValidationReport < Report
    def check_points
      datas = []
      return datas unless @report && @report['check_points']
      @report['check_points'].each do |d|
        next unless d['test_id']
        severity =d['severity']&.downcase&.to_sym
        result = d['result']&.downcase&.to_sym
        status = if severity == :error && result == :nok
                   :error
                 elsif severity == :warning && result == :nok
                   :warning
                 elsif result == :uncheck
                   :ignored
                 else
                   :ok
                 end
        check_point_error_count = d['check_point_error_count'].to_i
        count_error = status == :error ? check_point_error_count : 0
        count_warning = status == :warning ? check_point_error_count : 0
        datas << {
          name: d['test_id'],
          type: d['type'],
          status: status,
          severity: severity,
          count_error: count_error,
          count_warning: count_warning,
          check_point_errors: d['errors']
        }.tap{ |hash|
          hash[:error_or_warning] = (hash[:count_error] + hash[:count_warning]) > 0
        }
      end
      sort_datas(datas)
    end
  end
end
