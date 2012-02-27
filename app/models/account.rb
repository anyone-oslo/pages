# encoding: utf-8

class Account < ActiveRecord::Base

	belongs_to :account_holder, :class_name => 'User', :foreign_key => :account_holder_id
	validates_presence_of :name, :account_holder_id

	validate do |account|
		# TODO: accounts should be limited to 1
		account.make_key! unless account.key?
	end

	class << self

		def find_or_create
			account = Account.find( :first ) rescue nil
			unless account
				account_holder = User.find( :first ) rescue nil
				if account_holder
					account = Account.create( :name => PagesCore.config( :site_name ), :account_holder => account_holder )
				end
			end
			account
		end

	end

	def make_key!
		self.key = UUID.new.generate
	end

	def database_size
		# TODO: this is mysql specific
		res  = self.connection.select_all( "SHOW TABLE STATUS" )
		size = res.inject( 0 ) { |s,row| s += ( row["Index_length"].to_i + row["Data_length"].to_i ) }
	end

	def plan
		( self[:plan] && !self[:plan].empty? ) ? self[:plan] : 'basic'
	end

end
