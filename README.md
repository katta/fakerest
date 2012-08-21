# Fakerest

Fakerest is a simple tool based on sinatra which starts a http server (webrick) and exposes restful services based on the configuration specified in a YAML format.

## Prerequisites

These are required libraries to build and install fakerest:

* [rake](https://github.com/jimweirich/rake) - build tool for ruby
* [sinatra](https://github.com/sinatra/sinatra) - webrick based library to host rest services

## Building  

Follow these simple steps to create a gem and install it

    git clone git://github.com/katta/fakerest.git
    rake
    gem install pkg/fakerest-0.0.1.gem
    
Once you install this gem it creates an executable `fakerest` in the gems default executable directory. To find the gems executable directory use the command `gem environment` and look out for _EXECUTABLE DIRECTORY:_

For easy access update your `PATH` environment variable to point to a _EXECUTABLE DIRECTORY:_

## Usage

You can run fakerest using a command

    $ fakerest

this will display the instructions on all the command line arguments to use fakerest which looks like 
 
    Usage: fakerest.rb [options]
        -c, --config CONFIG_FILE         Confilg file to load request mappings (required)
        -p, --port PORT                  Port on which the fakerest to be run. Default = 1111
        -w, --views VIEWS_FOLDER         Folder path that contains the views. 
        -u, --uploads UPLOADS_FOLDER     Folder to which any file uploads to be stored.
        -h, --help                       Displays help message

### Examples

#### Specifying config file

    $ fakerest -c sample.yaml
    
`sample.yaml` is a config file which contains the configuration of all rest services you would like to host. It looks like 

    ---
    method : get
    path : /customer/:id
    response:
      content_file : customer
      content_type : json
      status_code : 200
    ---
    method : post
    path : /customer
    response:
      content_file : customer_created
      content_type : text/plain
      status_code : 200

#### Changing the default port

    $ fakerest -p 2222 -c sample.yaml
