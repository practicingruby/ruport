require "ruport"

class MyReport < Ruport::Formatter

  format :pdf, :base => Ruport::Format::PDF do

    def render
      doc.text "Hello Ruport", :align => :center
      doc.stroke_horizontal_rule
      doc.move_down(20)

      draw_table(params[:data])
      doc.move_down(20)
      doc.text "Goodbye Ruport"
      doc.render
    end

  end

  default_table_format_for :html, :csv

end

%w[pdf html csv].each do |ext|
  MyReport.render_file("foo.#{ext}", :data => Table("test/samples/addressbook.csv"))
end

