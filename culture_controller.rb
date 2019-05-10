class CultureController < ApplicationController
    def culture_header_partial
	  @blog = true
	  render :partial => 'layouts/headerculture'
    end
    def header_partial
	  @blog = true
	  render :partial => 'layouts/header'
	end
    def footer_partial
	  @blog = true
	  render :partial => 'layouts/footer'
	end
    def culture_footer_partial
	  @blog = true
	  render :partial => 'layouts/footerculture'
	end
    def hiring_partial
		@feed_xml = Feedjira::Feed.fetch_raw('http://hrm.zapbuild.com/job_openings/index.rss')
		data = Hash.from_xml(@feed_xml)
		@feed = []
		data["rss"]["channel"]["item"].each do |node|
			@feed << node
		end
		render :partial => 'about/hiring'
	end
end
