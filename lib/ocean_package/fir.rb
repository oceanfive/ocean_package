
module OceanPackage
  class Fir

    attr_accessor :token
    attr_accessor :change_log
    attr_accessor :ipa_file_path
    attr_accessor :log_path

    def initialize(token, change_log, ipa_file_path, log_path)
      @token = token
      @change_log = change_log
      @ipa_file_path = ipa_file_path
      @log_path = log_path
    end

    def info_cmd
      'fir -v'
    end

    def login_cmd
      cmd = 'fir login'
      cmd += ' -T ' + @token

      puts "fir login command: #{cmd}"

      return cmd
    end

    def publish_cmd
      cmd = 'fir publish'
      cmd += ' ' + @ipa_file_path
      cmd += ' -c ' + @change_log
      cmd += ' -Q'
      cmd += ' | tee ' + @log_path

      puts "fir publish command: #{cmd}"

      return cmd
    end

    def run
      login
      publish
    end

    def login
      system(info_cmd)
      res = system(login_cmd)
      puts "#{res}"
      puts "$? ====="
      puts $?
      puts "$0 ====="
      puts $0
    end

    def publish
      res = system(publish_cmd)
      puts "#{res}"
      puts "$? ====="
      puts $?
      puts "$0 ====="
      puts $0
    end
  end
end