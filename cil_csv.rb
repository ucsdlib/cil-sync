# Ruby script to test out parsing the CIL json data and dump to csv
#
# For now, we're concatenating the property hierarchy with colons
# So CIL: { "Image Files" [ "Mime_type": "application/zip" will be CIL:Image Files:Mime_type "application/zip"
require 'open-uri'
require 'json'
require 'byebug'
require 'csv'

# Hackety hacks, don't talk back
class CilCSV
  DATA_PATH = 'CIL_Public_Data_JSON/Version8_6/DATA/CIL_PUBLIC_DATA'.freeze
  attr_reader :cil_data

  def initialize
    @cil_data = {}
  end

  def start
    load_data
    CSV.open('cil.csv', 'wb', headers: true, write_headers: true, col_sep: '|') do |csv|
      csv << ['Identifier'] + cil_header_row
      cil_value_rows.each { |row| csv << row }
    end
  end

  def load_data
    json_files.each do |file|
      cil_data[file] = parse(file)
    end
  end

  def cil_header_row
    @cil_header_row ||= cil_data.values.map(&:keys).reduce(&:+).uniq
  end

  def cil_value_rows
    values = []
    cil_data.each_pair do |k, v|
      values << [k] + cil_header_row.map { |h| v.fetch(h, '') }
    end
    values
  end

  def json_files
    # For now just grab a couple samples
    # Dir.children(DATA_PATH).take(500)
    Dir.children(DATA_PATH)
  end

  def parse(cil_file)
    file = File.read(DATA_PATH + '/' + cil_file)
    metadata = JSON.parse(file)
    flatten_hash(metadata)
  end

  def flatten_hash(hash)
    hash.each_with_object({}) do |(k, v), h|
      if v.is_a? Hash
        flatten_hash(v).map do |h_k, h_v|
          h["#{k}.#{h_k}".to_sym] = h_v
        end
      else
        h[k] = String(v)
      end
    end
  end
end

CilCSV.new.start
