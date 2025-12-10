module ApplicationHelper
  def car_main_image(car, size: [ 400, 400 ], use_variant: true)
    return safe_car_placeholder if car.nil?

    if car.images.attached? && car.images.any?
      image = car.images.first

      if use_variant && defined?(MiniMagick)
        image_tag image.variant(resize_to_limit: size), class: "car-image w-full h-full object-cover"
      else
        image_tag url_for(image), class: "car-image w-full h-full object-cover"
      end
    else
      safe_car_placeholder
    end
  end

  def car_image_slider(car, height: "h-96", show_counter: true, show_navigation: true, show_pagination: true)
    return safe_car_placeholder if car.nil?

    if car.images.attached? && car.images.any?
      content_tag :div, class: "relative #{height} bg-gray-100" do
        # Slider Container
        slider_content = content_tag :div, class: "swiper-container h-full" do
          # Slides
          slides = content_tag :div, class: "swiper-wrapper" do
            car.images.map do |image|
              content_tag :div, class: "swiper-slide flex items-center justify-center" do
                image_tag url_for(image), class: "w-full h-full object-cover", alt: "#{car.brand} #{car.model}"
              end
            end.join.html_safe
          end

          # Navigation Buttons
          navigation = ""
          if show_navigation
            navigation = content_tag(:div, "", class: "swiper-button-prev swiper-button-white") +
                       content_tag(:div, "", class: "swiper-button-next swiper-button-white")
          end

          # Pagination
          pagination = ""
          if show_pagination
            pagination = content_tag(:div, "", class: "swiper-pagination swiper-pagination-white")
          end

          slides + navigation + pagination
        end

        # Image Counter
        counter = ""
        if show_counter && car.images.count > 1
          counter = content_tag :div, class: "absolute top-4 right-4 bg-black bg-opacity-50 text-white px-3 py-1 rounded-full text-sm font-medium" do
            content_tag(:span, "1", class: "current-slide") +
            content_tag(:span, " / ") +
            content_tag(:span, car.images.count.to_s, class: "total-slides")
          end
        end

        slider_content + counter
      end
    else
      content_tag :div, class: "#{height} bg-gradient-to-br from-gray-100 to-gray-200 flex items-center justify-center" do
        content_tag :div, class: "text-center" do
          content_tag(:i, "", class: "fas fa-car text-gray-400 text-6xl mb-4") +
          content_tag(:p, "No Images Available", class: "text-gray-500 text-lg")
        end
      end
    end
  end



  def car_images_for_slider(car)
    return [] if car.nil?

    if car.images.attached? && car.images.any?
      car.images.map { |image| url_for(image) }
    else
      []
    end
  end

  # WhatsApp link generator
  def admin_whatsapp_link(message = nil)
    return nil unless whatsapp_e164
    base_url = "https://wa.me/#{whatsapp_e164.delete('+')}"
    message ? "#{base_url}?text=#{ERB::Util.url_encode(message)}" : base_url
  end

  private

  def safe_car_placeholder
    content_tag :div, class: "w-full h-full bg-gradient-to-br from-gray-100 to-gray-200 rounded-lg flex items-center justify-center" do
      content_tag :i, "", class: "fas fa-car text-gray-400 text-3xl"
    end
  end

  # Get E164 format for API calls (WhatsApp Business API, Twilio, etc.)
  def whatsapp_e164
    parsed_whatsapp&.e164
  end

  # Memoized parsed phone object for performance
  def parsed_whatsapp
    return nil if AppConstants::ADMIN_WHATSAPP_NUMBER.blank?
    @parsed_whatsapp ||= Phonelib.parse(AppConstants::ADMIN_WHATSAPP_NUMBER)
  end

  # Sanitize WhatsApp link to prevent XSS
  def safe_whatsapp_link(url)
    return nil if url.blank?
    url.to_s.start_with?("https://wa.me/") ? url : nil
  end

  # Sanitize website URL to prevent XSS
  def safe_website_url(url)
    return nil if url.blank?
    url.to_s.match?(URI::DEFAULT_PARSER.make_regexp(%w[http https])) ? url : nil
  end
end
