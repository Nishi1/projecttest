class CareersController < ApplicationController
  layout 'main_site'
    
  def index
    feed
    #~ abort(data.inspect)
    # Set meta tags for main_site layout
    set_meta_tags :title => 'Careers - Zapbuild',
      :description => 'Zapbuild shapes your career by opening doors of job opportunities in different verticals like PHP, .NET, iPhone, Android, SEO, Graphic and UI designing, Quality Assurance & Mobile web development.',
      :keywords => 'careers in iphone, careers in php, careers in .net, careers in seo, careers in designing, careers in software testing, careers in software development, android app developer, mobile web development, custom mobile development'    
    @testimonials = TeamTestimonial.active.order("id DESC")
    @career = Career.new
        
  end
    
  def feed
		@feed_xml = Feedjira::Feed.fetch_raw('http://hrm.zapbuild.com/job_openings/index.rss')
		data = Hash.from_xml(@feed_xml)
		@feed = []
		data["rss"]["channel"]["item"].each do |node|
			@feed << node
		end
  end
    
  def create    
		feed
    if request.post? # data is submitted from contact form
      @career =  Career.new(contact_params)  
      if @career.valid? && @career.valid_with_captcha?  # if main site model validates the params data and captcha
        career_info = params[:career]
        if UserMailer.careers(career_info).deliver # sending email through user mailer function
				   UserMailer.careers_acknowledge(career_info).deliver # sending email through user mailer function
          #UserMailer.careers_acknowledge(career_info).deliver
          redirect_to '/thanks-for-applying' and return
          #flash.now[:notice] = 'Your application has been submitted successfully. Thank you for your interest in us.'
        else
          flash.now[:alert] = 'Some error occured. Please try again.'
        end     
        redirect_to careers_path and return        
      else
        @testimonials = TeamTestimonial.active.order("id DESC").limit(5) # to set testimonials before rendering index page again
        flash.now[:alert] = 'Application failed to submit. <a href="#last_section">Click here</a> to see error(s).'
        render 'index' and return
      end                      
    end
  end
    
  private
  #Note: Anything defined below this block will be private unless or until declared otherwise
    
  def contact_params
    params.require(:career).permit(:name, :email, :phone_no, :subject, :designation, :resume, :brief_description, :captcha, :captcha_key)	
  end
  
end
