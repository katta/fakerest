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

Use `-p` option to change the port on which the fakerest runs. By default it runs on `1111` port.

    $ fakerest -p 2222 -c sample.yaml

### Views

Views are the `erb` template files from which the content is read and is served as a response to a http request based on the view file specified in the configuration.

For e.g. In the following configuration, notice the value for `content_file`. Fakerest looks for a template `customer.erb` in the views folder.

    method : get
    path : /customer/:id
    response:
      content_file : customer # view file
      content_type : json 
      status_code : 200

Option `-w` can be used to tell Fakerest the folder in which the view files are held. A samile view file will look like this

    {
      "id" : "<%= params["id"] %>",
      "name" : "John"
    }

Notice the expression `<%= params["id"] %>` in the above template code, this will get evaluated before the response is served to the client by Fakerest using the parameters passed in the request.

In the above case if a request is made to a url `http://localhost:1111/customer/20` the response will be 

    {
      "id" : "20",
      "name" : "John"
    }

### File uploads

This is work in progess :)

### Credits

[Aravind](https://github.com/arvindsv) for his help in brainstorming this idea
[Vignesh](https://github.com/VigneshRE) for his contribution for the first version of this library