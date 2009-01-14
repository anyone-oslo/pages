#--
# Copyright (c) 2006-2007 Manual design as
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

require "soap/wsdlDriver" 

module Apparat
	class ApparatError < StandardError #:nodoc:
  	end
	class NoProductId < ApparatError #:nodoc:
	end
	class NoLicenseKey < ApparatError #:nodoc:
	end
	class NoSenderName < ApparatError #:nodoc:
	end
  

	# Client for Apparat's messaging API
	class MessagingClient
		attr_accessor :product_id, :sender

		# Create a new client. 
		#
		# Example:
		#
		#   client = Apparat::MessagingClient.new( "my_key" )
		#   client.sender     = "myName"
		#   client.product_id = 10
		#   
		# Attributes can also be set in the constructor call:
		# 
		#   client = Apparat::MessagingClient.new( "my_key", :product_id => 10, :sender => "myName" )
		#
		def initialize( key, options={} )
			@key        = key
			@wsdl       = options[:wsdl] || "http://sim.apparat.no/api/messaging/v1/wsdl"
			@product_id = options[:product_id]
			@sender     = options[:sender]
			@driver     = SOAP::WSDLDriverFactory.new( @wsdl ).create_rpc_driver 
		end

		# Send a message.
		#
		# examples: 
		#   
		#   msisdn = "4712345678"
		#   client.send( msisdn, "message" )
		#   client.send( msisdn, "message", :product_id => 15 )
		#   client.send( msisdn, "message", :sender => "myOtherName" )
		#
		def send( recipient, body, options={} )
			options[:sender]     ||= @sender
			options[:product_id] ||= @product_id
			recipient = cleanup_msisdn( recipient )
			
			raise NoProductId,  "Cannot send SMS without a product_id"    unless options[:product_id]
			raise NoLicenceKey, "Cannot send SMS, no license key set"     unless @key
			raise NoSenderName, "Cannot send SMS without a sender"        unless options[:sender]

			return nil  unless valid_msisdn?( recipient )
			uuid = @driver.SendSms( recipient, body, options[:sender], @key, options[:product_id], "utf-8" ) rescue nil
		end

		# Same as <tt>MessagingClient.send</tt>, except that it operates on an array of recipients and returns
		# an array of uuids.
		def bulk_send( recipients, body, options={} )
			recipients = [ recipients ].flatten.uniq
			uuids      = recipients.collect { |r| send( r, body, options ) }
		end

		# Returns boolean true if the provided number is a valid msisdn.
		def valid_msisdn?( msisdn )
			( msisdn.match( /^47[\d]{8}$/ ) ) ? true : false 
		end

		# Cleanup phone number, remove non-numeric chars and add the country prefix if necessary.
		def cleanup_msisdn( msisdn )
			msisdn.gsub!( /[^\d]/, '' )
			if msisdn.length == 8
				msisdn = "47"+msisdn
			end
			if msisdn.length > 10
				msisdn = msisdn.gsub( /^[0]+/, '' )
			end
			return msisdn
		end

	end 
end
