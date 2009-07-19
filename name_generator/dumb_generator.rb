module NamesGenerator
  def pick_name(language)
    File.open("#{language.to_s}_names.txt", 'r') do |file|
      @names = file.readlines
    end
    File.open("#{language.to_s}_surnames.txt", 'r') do |file|
      @surnames = file.readlines
    end
    srand
    puts "#{@names.choice.strip} #{@surnames.choice.strip}"
  end
end