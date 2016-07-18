module IevkitViews
  class Report

    include IevkitViews::ApplicationHelper
    attr_reader :result, :datas, :search

    def initialize(referential, link_action, type_report, link_validation = nil, search = nil)
      @datas = {}
      @result = :error
      ievkit = ::Ievkit::Job.new(referential)
      report = ievkit.get_job(link_action)
      @report = report[type_report] if report
      @validation = link_validation ? ievkit.get_job(link_validation) : nil
      if @validation && @validation['validation_report'] && @validation['validation_report']['result']
        @result = @validation['validation_report']['result'].downcase.to_sym
      end
      @search = search
    end

    def sort_datas(datas)
      sorted_by = { error: [], warning: [], ok: [], ignored: [], '': [] }
      datas.flatten.each{ |d|
        sorted_by[d[:status]] << d
      }
      sorted_by.each{ |key, value|
        sorted_by[key] = value.sort_by{ |a| [a[:count_error], a[:count_warning]] }.reverse
      }
      [].tap{ |a|
        a << sorted_by.map{ |_k, v| v }
      }.flatten!
    end

    def search_for(datas)
      return datas unless search.present?
      files = []
      files << datas.select{ |value| value.to_s.downcase =~/#{search.downcase}/i }
      files.flatten!
    end

    def sum_report(datas)
      {}.tap{ |hash|
        datas.map{ |el| el[:type] }.uniq.each do |type|
          hash[type] = {
            ok: badge_count(datas, type, :ok),
            error: badge_count(datas, type, :error, :warning),
            ignored: badge_count(datas, type, :ignored)
          }
        end
      }
    end

    def errors
      clean_errors = []
      return clean_errors unless @validation
      errors = @validation['validation_report']['errors']
      errors.each do |error|
        error = key_to_sym(error)
        error[:source_label] = error[:source][:label]
        error[:source_objectid] = error[:source][:objectid]
        error[:filename] = error[:source][:file][:filename] if error[:source][:file]
        if error[:target]
          error[:target].each_with_index do |target, index|
            target = key_to_sym(target)
            error[:target][index] = target
            error[:"target_#{index}_label"] = target[:label]
            error[:"target_#{index}_objectid"] = target[:objectid]
          end
        end
        error[:test_name] = I18n.t("compliance_check_results.details.#{error[:test_id]}")
        error[:error_name] = I18n.t("compliance_check_results.details.detail_#{error[:error_id]}", error)
        clean_errors << error
      end
      clean_errors
    end

    protected

    def key_to_sym(el)
      return el unless el.is_a? Hash
      Hash[el.map { |k, v| [
        k.to_sym, key_to_sym(v)
      ] }]
    end

  end
end
