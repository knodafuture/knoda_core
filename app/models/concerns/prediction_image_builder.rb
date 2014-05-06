module PredictionImageBuilder extend ActiveSupport::Concern
	included do
		has_attached_file :shareable_image
		do_not_validate_attachment_file_type :shareable_image
	end

	module ClassMethods
	end

	def build_image
		puts "BUILD IMAGE"
		puts self.to_json
		html = render(:template => 'prediction-screenshot.html.erb', :layout => false, :locals => {prediction: self})
		kit = IMGKit.new(html, :height => 640, :width => 640, :quality => 100)
		img = kit.to_img(:jpg)
		file  = Tempfile.new(["template_#{self.id}", '.jpg'], "#{Rails.root}/tmp", :encoding => 'ascii-8bit')
		file.write(img)
		file.flush
		self.shareable_image = file
		self.save!
		file.unlink
	end


	def background_image
		tag = tags.first().to_s
		image_name = ""
		if tag == "SPORTS"
			image_name = "namath_640.jpg"
		elsif tag == "BUSINESS" or tag == "STOCKS"
			return "bitcoin_640.jpg"
		elsif tag == "POLITICS" or tag == "PERSONAL"
			return "stockmkt_640.jpg"
		elsif tag == "ENTERTAINMENT"
			return "goldenglobes_640.jpg"
		else
			return "docbrown_640.jpg"
		end
	end

	def shareable_image
		if self.shareable_image.exists?
			self.shareable_image
		else
			nil
		end
	end

end
