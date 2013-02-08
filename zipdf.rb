#! ruby -Ks

require 'rubygems'
require 'zip/zipfilesystem'
require 'prawn'
require 'fileutils'

OUTPUT_PATH = ".\\temp\\"

if ARGV[0].nil?
    print "�t�@�C�������w�肳��Ă��܂���...\n\n"
    exit(-1)
end

if File.extname(ARGV[0]) != ".zip"
    print "zip�t�@�C�����w�肵�Ă�������...\n\n"
    exit(-1)
end

print "zipdf ���s���܂�...\n\n"

# �w�肵���t�H���_��ZIP�t�@�C����񋓂��A
# ���ׂď�������܂Ń��[�v
zip_file = ARGV[0]
    
pdf_name = File.basename( zip_file , ".zip" )
print "#{zip_file} => #{pdf_name}.pdf "

Prawn::Document.generate(pdf_name + ".pdf", :size => "B5", :margin => 0) do
    
    index = 0
    file_list = []

    # ZIP�t�@�C���̒��̃t�@�C���������o���A�\�[�g����
    Zip::ZipInputStream.open( zip_file ) do |input_stream|
        while entry = input_stream.get_next_entry()
            # �t�@�C���ȊO�̓p�X
            next unless entry.file?
            file_list << entry.name
        end
    end

    file_list.sort!

    # ZIP�t�@�C����W�J���ĉ摜�����o��

    file_list.each do |f|
        zip = Zip::ZipFile.open( zip_file )
        
        entry = zip.find_entry(f)
        # �������Ȃ���΃X�L�b�v
        next if entry.nil?
        
        if index % 10 == 0
            print "."
        end
        
        d = File.dirname(entry.name)
        FileUtils.makedirs(OUTPUT_PATH + d)
        source = OUTPUT_PATH + entry.name
        
        start_new_page() if index > 0

        # �摜���o��
        File.open(source, "w+b") do |wf|
            entry.get_input_stream do |stream|
                wf.puts(stream.read())
            end
        end

        # �W�J�����摜��PDF�֊i�[����
        image source,
            :fit =>  bounds.top_right,
            :position => :center,
            :vposition => :center

        # �W�J�����摜�̌�n��
        File.delete source
        index += 1
    end
    print "\n"
    render
end

