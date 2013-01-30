# encoding: utf-8

namespace :pages do
  namespace :export do
    desc "Outputs all site content as XML"
    task :xml => :environment do
      builder = Builder::XmlMarkup.new(:indent => 2)
      builder.instruct!

      xml_data = builder.export do
        User.find(:all).to_xml(
          :builder       => builder,
          :skip_instruct => true,
          :except        => [
            :delta, :is_super_admin, :is_venue_admin, :is_reviewer,
            :persistent_data, :sms_sender, :token, :hashed_password
          ]
        )
        Page.root_pages(:all => true).to_xml(
          :builder       => builder,
          :skip_instruct => true,
          :pages         => :all,
          :comments      => true,
          :images        => true
        )
      end
      puts xml_data
    end
  end
end
