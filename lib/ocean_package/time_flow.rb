module OceanPackage
  class TimeFlow

    # 开始时间
    attr_accessor :start_time
    # git拉取仓库时间
    attr_accessor :pull_git_time
    # 安装相关依赖时间
    attr_accessor :pull_dependency_time
    # clean 项目时间
    attr_accessor :clean_time
    # archive 项目时间
    attr_accessor :archive_time
    # 加固 项目时间
    attr_accessor :reinforce_time
    # 导出ipa包时间
    attr_accessor :export_time
    # 上传ipa到分发平台时间
    attr_accessor :upload_ipa_time
    # 上传dsym符号表时间
    attr_accessor :upload_dsym_time
    # 群通知时间(钉钉群)
    attr_accessor :notify_group_time
    # 整个流程完成时间
    attr_accessor :end_time

    public

    def self.instance
      @instance ||= new
    end

    class << self
      attr_writer :instance
    end

    def initialize()
      @start_time = get_seconds
      @pull_git_time = 0
      @pull_dependency_time = 0
      @clean_time = 0
      @archive_time = 0
      @reinforce_time = 0
      @export_time = 0
      @upload_ipa_time = 0
      @upload_dsym_time = 0
      @notify_group_time = 0
    end

    def get_seconds
      Time.now.to_i
    end

    def point_pull_git_time
      @pull_git_time = get_seconds
    end

    def point_pull_dependency_time
      @pull_dependency_time = get_seconds
    end

    def point_clean_time
      @clean_time = get_seconds
    end

    def point_archive_time
      @archive_time = get_seconds
    end

    def point_reinforce_time
      @reinforce_time = get_seconds
    end

    def point_export_time
      @export_time = get_seconds
    end

    def point_upload_ipa_time
      @upload_ipa_time = get_seconds
    end

    def point_upload_dsym_time
      @upload_dsym_time = get_seconds
    end

    def point_notify_group_time
      @notify_group_time = get_seconds
    end

    def point_start_time
      @start_time = get_seconds
    end

    def point_end_time
      @end_time = get_seconds
    end

    def make_all_points
      params = {
        "startTime" => @start_time,
        "pullGitTime" => @pull_git_time,
        "pullDependencyTime" => @pull_dependency_time,
        "cleanTime" => @clean_time,
        "archiveTime" => @archive_time,
        "reinforceTime" => @reinforce_time,
        "exportTime" => @export_time,
        "uploadIpaTime" => @upload_ipa_time,
        "uploadDsymTime" => @upload_dsym_time,
        "notifyGroupTime" => @notify_group_time,
        "endTime" => @end_time
      }
      params
    end

    module Mixin
      def time_flow
        TimeFlow.instance
      end
    end

  end
end
