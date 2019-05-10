class ContactController < ApplicationController
  layout 'main_site'
  
  #  include Obfuscate
  #  helper_method :cipher, :cipher_key, :encrypt # these methods are declared in Obfuscate concern. Declared here to be available in view of portfolio
  
  def index
    @random_image_number = 1
    unless cookies[:add_image_number].nil?
      @random_image_number = cookies[:add_image_number].to_i == 3 ? 1 : cookies[:add_image_number].to_i + 1
    end
    cookies[:add_image_number] =  @random_image_number
    # Set meta tags for main_site layout
    set_meta_tags :title => 'Contact Us, Software Development Company India - Zapbuild',
      :description => 'Offshore website development company, Zapbuild is headquartered in Mohali. Zapbuild Technologies is one of the leading web development companies in Chandigarh, India.',
      :keywords => 'web development company India, software development company India, software development company Chandigarh, offshore web development company Mohali, custom web application development India, android app development India, iphone app development India, open source website development India'    
    @contact =  Contact.new
  end
  
  def create
    if request.xhr? #if request is ajax i.e data is submitted from get in touch form
      get_in_touch_process # call to this function
    elsif request.post? # data is submitted from contact form
      #~ abort(contact_params.inspect)
      @contact =  Contact.new(contact_params)  
      if @contact.valid? && @contact.valid_with_captcha?  # if main site model validates the params data and captcha
        contact_info = params[:contact]
        if contact_info[:email].present? && contact_info[:message].present?
          if UserMailer.contact_us(contact_info).deliver #sending email through user mailer function
            redirect_to '/thanks-for-contacting-us' and return
            #flash.now[:notice] = 'Your message has been submitted successfully.'
          else
            flash.now[:alert] = 'Some error occured. Please try again.'
          end
          redirect_to contact_index_path and return          
        end
      else   
        render 'index' and return
      end
    end
  end
  
  def view_on_map
    if request.xhr?
      case params[:add].to_i
      when 1
        @lat = 30.711446
        @lng = 76.689033
      when 2
        @lat = 29.8858989
        @lng = -98.9646973
      else
        @lat = -33.8024773
        @lng = 150.9949932
      end
      respond_to do |format| #send data as html       
        format.html do
          render :partial => 'view_on_map', :layout => false # dynamic_image_content is a partial view to render dynamic content
        end
      end
    end
  end
  
  def thanks
	if !request.referrer.nil?
      set_meta_tags :title => 'Thanks for Contacting - Zapbuild', :noindex => true, :nofollow => true
      @heading = 'Thank you for your interest in us.'
      case params[:slug]
      when 'thanks-for-getting-in-touch'      
        @innerText = 'Thank you for your interest in us. We will get back to you soon.'
      when 'thanks-for-applying'     
        @innerText = 'Your application has been submitted successfully. Thank you for your interest in us.'
      when 'thanks-for-contacting-us'      
        @innerText = 'Thank you for contacting Zapbuild! We will get back to you soon.'
	  when 'thanks-for-payment'
		@innerText = 'Thank you for your payment.'
	  when 'thanks-for-contacting-zvid'
		@innerText = 'Thank you for contacting Zapbuild for Zvid! We will get back to you soon.'
	  else
        raise ActionController::RoutingError.new('Not Found')
      end
    else
		if params['p'].present?
			set_meta_tags :title => 'Payment Thanks - Zapbuild'
			@innerText = 'Thank you for your payment.'
		else
			redirect_to '/zapbuild-ccav-payment'
		end
    end
  end
  
  private
  #Note: Anything defined below this block will be private unless or until declared otherwise  
  
  # Function: get_in_touch_process
  # Description: Verifies get in touch form with model validation and accordingly email is sent
  # Args: form data in params via ajax request
  # Created By: Virender Singh
  # Modified By: Shiv k. Agg.
  
  def get_in_touch_process
    require "net/http"
	require "uri"
    @contact_us =  Contact.new(contact_params)
    respond_to do |format|
      if @contact_us.valid? && @contact_us.valid_with_captcha?  # if main site model validates the params data and captcha   
        contact_info = params[:contact]
        userIP = request.remote_ip
		setURL = "http://www.geoplugin.net/json.gp?ip="+userIP
		uri = URI.parse(setURL)
		http = Net::HTTP.new(uri.host, uri.port)
		request = Net::HTTP::Get.new(uri.request_uri)
		response = http.request(request)
		data = JSON.parse(response.body)
		contact_info['location'] = data['geoplugin_city']+', '+data['geoplugin_region']+', '+data['geoplugin_countryName']
		  					
        if contact_info[:email].present? && contact_info[:message].present?
          if UserMailer.get_in_touch(contact_info).deliver #sending email through user mailer function            
            format.json {render json: {'response' => 'email_success'}}
          else
            format.json {render json: {'response' => 'email_failed'}}
          end  
        end
      else        
        format.json { render json: @contact_us.errors } # if model does not validate true, then sending model errors as response in json format
      end
    end
  end
  
  def contact_params
    params.require(:contact).permit(:name, :email, :contact_no, :subject, :attachment, :message, :captcha, :captcha_key)	
  end 
  
end
