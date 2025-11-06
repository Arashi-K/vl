require_relative 'executer'

file_path, *args = ARGV

if file_path.nil? || file_path.empty?
  puts 'vl usage: vl <file path>'
  return
end

if !File.exist?(file_path)
  puts "vl error: file does not exists (#{Dir.pwd}/#{file_path})"
  return
end

code = File.read(file_path)
working_dir = File.dirname(file_path)
begin
  res = Executer.execute(code, args, working_dir)
  puts res.join(' ')
rescue Executer::ParseError
  puts 'vl error: something went wrong'
end
