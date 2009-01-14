class Postnummer
	
	class << self
		def name(id)
			get_line(id)[1]
		end
		def municipality_id(id)
			get_line(id)[2]
		end
		def municipality(id)
			get_line(id)[3]
		end
		def exists?(id)
			(name(id)) ? true : false
		end
		def find_by_name(name)
			get_data.select{ |l| l[1] == name.upcase || l[3] == name.upcase }.map{ |l| l.first }
		end
		def valid_id?(id)
			( parse_id(id) =~ /^\d\d\d\d$/ ) ? true : false
		end
		def valid?(id)
			( valid_id?(id) && exists?(id) ) ? true : false
		end

		protected
		def data_file
			File.join(File.dirname(__FILE__),'postnummer/postnummer.tab')
		end
		def get_data
			@@data ||= File.open(data_file,'r'){ |fh| fh.read }.split("\n").compact.map{ |line| line.split("\t").compact }
		end
		def get_line(id)
			get_data.each do |l|
				return l if l.first == parse_id(id)
			end
			return [nil,nil,nil,nil]
		end
		def parse_id(id)
			id.to_s.gsub(/[^\d]/,'')
		end
	end
	
end