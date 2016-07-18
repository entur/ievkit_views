module IevkitViews
  module ApplicationHelper
    def badge_count(datas, type = nil, *status)
      datas = datas.select{ |d| status.include? d[:status] }
      type ? datas.count{ |d| d[:type] == type } : datas.count
    end

    def get_icon(name, count_error = 0, count_warning = 0)
      return 'question-sign' unless name.present?
      name = name.to_sym.downcase
      if name == :error && count_error > 0
        'minus-sign'
      elsif name == :warning || (count_warning > 0 && name != :ignored)
        'alert'
      elsif name == :ignored
        'ban-circle'
      else
        'ok-sign'
      end
    end

    def get_icon_title(name, count_error = 0, count_warning = 0)
      name = name.to_sym.downcase
      fs_status = if (count_warning > 0 && name != :ignored)
                    'warning'
                  else
                    name.to_s
                  end
      I18n.t("report_results.icons.title.#{fs_status.downcase}_txt", default: fs_status.to_s.humanize)
    end
  end
end
