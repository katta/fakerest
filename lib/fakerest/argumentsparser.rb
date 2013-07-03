require 'optparse'


module FakeRest

  class ArgumentsParser

    def parse(args)
      options = {}

      optparse = OptionParser.new do |opts|
        opts.banner = "Usage: fakerest.rb [options]"

        options[:port] = 1111
        options[:config] = nil
        options[:views] = 'views'
        options[:uploads] = 'uploads'
        options[:bind] = 'localhost'

        opts.on("-c","--config CONFIG_FILE","Confilg file to load request mappings (required)") do |cfg|
          options[:config] = cfg
        end

        opts.on("-p","--port PORT","Port on which the fakerest to be run. Default = 1111") do |prt|
          options[:port] = prt
        end

        opts.on("-o","--bind server hostname or IP address","String specifying the hostname or IP address of the interface to listen on . Default = localhost") do |prt|
          options[:bind] = prt
        end

          opts.on("-w","--views VIEWS_FOLDER","Folder path that contains the views. Default = <WORKING_DIR>/views") do |views|
          options[:views] = views
        end

        opts.on("-u","--uploads UPLOADS_FOLDER","Folder to which any file uploads to be stored. Default = <WORKING_DIR>/uploads") do |uploads|
          options[:uploads] = uploads
        end

        opts.on( "-h", "--help", "Displays help message" ) do
          puts opts
          exit
        end
      end
      optparse.parse!(args)


      if(options[:config] == nil)
        puts optparse
        exit(-1)
      end

      options
    end
  end
end

