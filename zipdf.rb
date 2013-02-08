#! ruby -Ks

require 'rubygems'
require 'zip/zipfilesystem'
require 'prawn'
require 'fileutils'

OUTPUT_PATH = ".\\temp\\"

if ARGV[0].nil?
    print "ファイル名が指定されていません...\n\n"
    exit(-1)
end

if File.extname(ARGV[0]) != ".zip"
    print "zipファイルを指定してください...\n\n"
    exit(-1)
end

print "zipdf 実行します...\n\n"

# 指定したフォルダにZIPファイルを列挙し、
# すべて処理するまでループ
zip_file = ARGV[0]
    
pdf_name = File.basename( zip_file , ".zip" )
print "#{zip_file} => #{pdf_name}.pdf "

Prawn::Document.generate(pdf_name + ".pdf", :size => "B5", :margin => 0) do
    
    index = 0
    file_list = []

    # ZIPファイルの中のファイル名を取り出し、ソートする
    Zip::ZipInputStream.open( zip_file ) do |input_stream|
        while entry = input_stream.get_next_entry()
            # ファイル以外はパス
            next unless entry.file?
            file_list << entry.name
        end
    end

    file_list.sort!

    # ZIPファイルを展開して画像を取り出す

    file_list.each do |f|
        zip = Zip::ZipFile.open( zip_file )
        
        entry = zip.find_entry(f)
        # 見つけられなければスキップ
        next if entry.nil?
        
        if index % 10 == 0
            print "."
        end
        
        d = File.dirname(entry.name)
        FileUtils.makedirs(OUTPUT_PATH + d)
        source = OUTPUT_PATH + entry.name
        
        start_new_page() if index > 0

        # 画像を出力
        File.open(source, "w+b") do |wf|
            entry.get_input_stream do |stream|
                wf.puts(stream.read())
            end
        end

        # 展開した画像をPDFへ格納する
        image source,
            :fit =>  bounds.top_right,
            :position => :center,
            :vposition => :center

        # 展開した画像の後始末
        File.delete source
        index += 1
    end
    print "\n"
    render
end

