
module OceanPackage
  module Log

    def Log.info(msg)
      logger = Logger.new(STDOUT)
      logger.info(msg)
    end

    def Log.error(msg)
      logger = Logger.new(STDOUT)
      logger.error(msg)
    end

    # 分割线
    def Log.divider
      logger = Logger.new(STDOUT)
      logger.info("=========")
    end

    # 换行
    def Log.new_line
      logger = Logger.new(STDOUT)
      logger.info("\n")
    end
  end
end

