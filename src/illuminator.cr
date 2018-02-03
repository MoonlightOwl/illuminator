require "./illuminator/*"
require "kemal"

module Illuminator
  error 404 do
    render "src/views/404.ecr"
  end
  get "/" do
    render "src/views/index.ecr"
  end

  Kemal.config.port = 1095
  Kemal.run
end
