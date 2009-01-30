require "rubygems"
require "prawn"
require "prawn/layout"
require  "#{File.dirname(__FILE__)}/../../vendor/fatty/lib/fatty"

module Ruport

  module Format
    class PDF < Fatty::Format

      write_mode "wb"

      def doc
        @doc ||= Prawn::Document.new
      end

      def draw_table(data, options={})
        headers = options[:headers] || data.column_names
        options[:headers] = headers unless headers.empty?
        options[:row_colors] ||= :pdf_writer
        options[:position] ||= :center
          
        data = data.map { |e| e.to_a }
        doc.table data, options
      end

      def self.render_as_table
        define_method :render do
          draw_table params[:data], params[:format].merge(:headers => params[:headers])
          doc.render
        end
      end
    end

    class HTML < Fatty::Format

      def draw_table(data, options={})
        headers = options[:headers] || data.column_names
        output  = "<table>"

        unless headers.empty?
          output << "<tr>"
          headers.each { |e| output << "<th>#{e}</th>" }
          output << "</tr>"
        end

        data.each do |r|
          output << "<tr>"
          r.each { |e| output << "<td>#{e}</td>" }
          output << "</tr>"
        end

        output << "</table>"
      end

      def self.render_as_table
        define_method :render do
          draw_table params[:data], :headers => params[:headers]
        end
      end
    end

    class CSV < Fatty::Format
      def draw_table(data, options={})
        headers = options[:headers] || data.column_names
        output = ""

        unless headers.empty?
          output << FCSV.generate_line(headers)
        end

        data.each do |r|
          output << FCSV.generate_line(r.to_a)
        end

        return output
      end

      def self.render_as_table
        define_method :render do
          draw_table params[:data], :headers => params[:headers]
        end
      end
    end

  end

  class Formatter < Fatty::Formatter
    
    DEFAULT_FORMATS = { :html => Ruport::Format::HTML,
                        :pdf  => Ruport::Format::PDF,
                        :csv  => Ruport::Format::CSV }

    def self.default_table_format_for(*formats) 
      formats.each do |f|
        format f, :base => DEFAULT_FORMATS[f] do
          render_as_table
        end
      end
    end

    class Table < Fatty::Formatter
      format :pdf, :base => Ruport::Format::PDF do
        render_as_table
      end

      format :html, :base => Ruport::Format::HTML do
        render_as_table
      end
    end
  end
end
