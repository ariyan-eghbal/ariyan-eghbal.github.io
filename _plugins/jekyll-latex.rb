# Authored my Maxfan http://github.com/Maxfan-zone http://maxfan.org
# This is used to convert tikz code into svg file and load in you jekyll site
#
# Install:
#
#   1. Copy this file in your _plugins/ directory. You can customize it, of course.
#   2. Make sure texlive and pdf2svg are installed on your computer.
#   3. Set path to pdf2svg in _config.yml in "pdf2svg" variable
#
# Input:
#   
#   {% tikz filename %}
#     \tikz code goes here 
#   {% endtikz %}
#
# This will generate a /img/post-title-from-filename/filename.svg in your jekyll directory
# 
# And then return this in your HTML output file:
#   
#   <embed src="/img/post-title-from-filename/tikz-filename.svg" type="image/svg+xml" />
#   
# Note that it will generate a /_tikz_tmp directory to save tmp files.
#

module Jekyll
  module Tags
    class Latex < Liquid::Block
      def initialize(tag_name, markup, tokens)
        super
        @file_name = markup.gsub(/\s+/, "")
      end

      def render(context)
        tikz_code = super 

        tmp_directory = File.join(Dir.pwd, "_tikz_tmp", File.basename(context["page"]["url"], ".*"))
        tex_path = File.join(tmp_directory, "#{@file_name}.tex")
        pdf_path = File.join(tmp_directory, "#{@file_name}.pdf")
        FileUtils.mkdir_p tmp_directory

        dest_directory = File.join(Dir.pwd, "svg", File.basename(context["page"]["url"], ".*"))
        dest_path = File.join(dest_directory, "#{@file_name}.svg")
        FileUtils.mkdir_p dest_directory

        pdf2svg_path = context["site"]["pdf2svg"]

        # if the file doesn't exist or the tikz code is not the same with the file, then compile the file
        if !File.exist?(tex_path) or !tikz_same?(tex_path, tikz_code) or !File.exist?(dest_path)
          File.open(tex_path, 'w') { |file| file.write("#{tikz_code}") }
          system("pdflatex  -interaction=nonstopmode -output-directory #{tmp_directory} #{tex_path}")
          system("#{pdf2svg_path} #{pdf_path} #{dest_path}")
        end

        web_dest_path = File.join("/svg", File.basename(context["page"]["url"], ".*"), "#{@file_name}.svg")
        "<div style='text-align: center;'><embed style='max-width: 90%;' src=\"#{web_dest_path}\" type=\"image/svg+xml\" /></div>"
      end

      private

      def tikz_same?(file, code)
        File.open(file, 'r') do |file|
          file.read == code
        end
      end

    end
  end
end

Liquid::Template.register_tag('latex', Jekyll::Tags::Latex)
