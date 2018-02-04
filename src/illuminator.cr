require "./illuminator/*"
require "./config"
require "./log"
require "kemal"

module Illuminator
  config = Config.new "./config/illuminator.conf"

  files = Dir.children(config.get("path")).sort.reverse

  error 404 do
    render "src/views/404.ecr"
  end

  def self.render_index(path, files)
    current_file = files.first
    log = Log.new(path + current_file)
    render "src/views/index.ecr"
  end

  get "/index.html" do
    render_index(config.get("path"), files)
  end
  get "/" do
    render_index(config.get("path"), files)
  end

  get "/:filename" do |env|
    current_file = env.params.url["filename"]
    if File.exists? config.get("path") + current_file
      log = Log.new(config.get("path") + current_file)
      render "src/views/index.ecr"
    else
      render "src/views/404.ecr"
    end
  end

  Kemal.config.port = config.get("port").to_i
  Kemal.run
end
