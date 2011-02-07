#!/usr/bin/env /opt/ruby1.8/bin/ruby
require 'rubygems'
require 'erubis'
require 'flickr'

## Settings
config = YAML.load(File.open( File.dirname(__FILE__) + "/config.yml" ))
OUTPUT_DIR = config['output_dir']
TEMPLATE_FILE = config['template_file']
DISPLAY_IMAGES = config['display_images']
DEBUG = config['debug']

FLICKR_API_KEY = config['flickr_api_key']
FLICKR_API_SECRET = config['flickr_api_secret']

USERS = config['users']

## Main
images = Array.new    # An array of images from all users.
fav_owners = Hash.new # A hash of people who favorited the image.

## Flickr API
flickr = Flickr.new(:api_key => FLICKR_API_KEY)
USERS.each{|u|
  begin
    user = flickr.users(u)
    if user
      user.favorites.each{|fav_img|
        fav_owners["#{fav_img.id}-#{fav_img.instance_variable_get('@date_faved')}"] = user.username
        puts "#{fav_img.title} faved by #{user.username}" if DEBUG
        images.push fav_img
      }
    end
  rescue
  end
}

images.sort!{|a,b| b.instance_variable_get("@date_faved") <=> a.instance_variable_get("@date_faved") }
images = images[0..DISPLAY_IMAGES]


## Filling up the template.
template_src = File.read(TEMPLATE_FILE)
template = Erubis::Eruby.new(template_src)
output = template.result(binding())

File.open(OUTPUT_DIR + "/index.html", 'w') {|f| f.write(output) }
