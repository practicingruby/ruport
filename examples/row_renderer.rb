require "ruport"

class CSV2Something < Ruport::Renderer
  required_option :file
  stage :table_body

  module Helpers
    def table_feeder
      Table(options.file,:has_names => false) { |t,r| yield(r) }
    end
  end

end

class HTML < Ruport::Formatter::HTML

  renders :html, :for => CSV2Something

  def layout
    output << "<html><div id='ruport'><table>\n"
    yield
    output << "</table></div></html>\n"
  end
  
  def build_table_body
    table_feeder { |r| render_row(r) }
  end
end

class Text < Ruport::Formatter::Text
  renders :text, :for => CSV2Something

  def build_table_body
    table_feeder { |r|  output << r.to_a.join("$") }
  end
 
end

CSV2Something.render_html(:file => "example.csv",:io => STDOUT)
