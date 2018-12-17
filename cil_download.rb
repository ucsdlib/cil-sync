# Ruby script to test out parsing the CIL json data
#
require 'open-uri'
require 'json'

data_path = 'CIL_Public_Data_JSON/Version8_6/DATA/CIL_PUBLIC_DATA'
default_file_types = ['jpg', 'zip']
video_base_url = 'https://cildata.crbs.ucsd.edu/media/videos/'
image_base_url = 'https://cildata.crbs.ucsd.edu/media/images/'

# For now just grab a couple samples
results = Dir.children(data_path).take(100)

results.each do |json_record|
  identifier = json_record.split('.')[0]

  file = File.read(data_path + '/' + json_record)
  metadata = JSON.parse(file)

  if metadata['CIL_CCDB']['Data_type']['Video']
    # according to the README we can get jpg, flv, zip
    default_file_types.each do |file_type|
      `wget #{video_base_url}/#{identifier}/#{identifier}.#{file_type}`
    end
    `wget #{video_base_url}/#{identifier}/#{identifier}.flv`
  else
    # acconrding to the README we can get jpg, tif, zip
    default_file_types.each do |file_type|
      `wget #{image_base_url}/#{identifier}/#{identifier}.#{file_type}`
    end
    `wget #{video_base_url}/#{identifier}/#{identifier}.tif`
  end
end