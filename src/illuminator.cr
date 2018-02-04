require "./illuminator/*"
require "./config"
require "kemal"

module Illuminator
  config = Config.new "./config/illuminator.conf"

  error 404 do
    render "src/views/404.ecr"
  end
  get "/" do
    render "src/views/index.ecr"
  end

  Kemal.config.port = config.get("port").to_i
  Kemal.run
end
