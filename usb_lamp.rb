require "libusb"
require "ostruct"

DC_VENDOR = 0x1D34
DC_PRODUCT= 0x0004

USB_TYPE_CLASS      = 0x20
USB_RECIP_INTERFACE = 0x01

class UsbLamp
  attr_accessor :device,:color

  def initialize
    begin
      @usb    = LIBUSB::Context.new
      @device = @usb.devices(:idVendor => DC_VENDOR, :idProduct => DC_PRODUCT).first
    rescue LIBUSB::ERROR_ACCESS
      abort("No permission to access USB device!")
    rescue LIBUSB::ERROR_BUSY
      abort("The USB device is busy!")
    rescue NoMethodError
      abort("Could not find USB device!")
    end
  end

  def color(color_struct)
    @color = color_struct
    if @color.red < 0
      @color.red = 0
    end
    if @color.green < 0
      @color.green = 0
    end
    if @color.blue < 0
      @color.blue = 0
    end
    color_msg = [@color.red,@color.green,@color.blue, 0x00, 0x00, 0x00, 0x00, 0x05]
    send_msg(color_msg)
  end

  def red
    the_color = OpenStruct.new(:red=>0xFF,:green=>0x00, :blue=>0x00)
    color(the_color)
  end

  def green
    the_color = OpenStruct.new(:red=>00,:green =>0xFF, :blue=>0x00)
    color(the_color)
  end

  def blue
    the_color = OpenStruct.new(:red=>0x00,:green=>0x00, :blue=>0xFF)
    color(the_color)
  end

  def white
    the_color = OpenStruct.new(:red=>0x00,:green=>0x00, :blue=>0x00)
    color(the_color)
  end

  def fading(delay, new_color)
       max_step = 0x40
       red_delta = (new_color.red - @color.red)/max_step
       green_delta = (new_color.green - @color.green)/max_step
       blue_delta = (new_color.blue - @color.blue)/max_step
       puts blue_delta
       (0..max_step).each do |i|
         sleep(delay/(max_step+1).to_f )
         current_color = OpenStruct.new
         current_color.red = @color.red + red_delta
         current_color.green = @color.green + green_delta
         current_color.blue = @color.blue + blue_delta
         color(current_color)
       end
  end


  private

    def send_msg(message)
      #setup data
      data1 = [0x1f, 0x02, 0x00, 0x2e, 0x00, 0x00, 0x2b, 0x03]
      data2 = [0x00, 0x02, 0x00, 0x2e, 0x00, 0x00, 0x2b, 0x04]
      data3 = [0x1f, 0x02, 0x00, 0x2e, 0x00, 0x00, 0x2b, 0x03]
      @device.open_interface(0) do |handle|
        [data1,data2,data3,message].each do |msg|
          handle.control_transfer(:bmRequestType => USB_TYPE_CLASS | USB_RECIP_INTERFACE,
                                  :bRequest      => 0x09,
                                  :wValue        => 0x200,
                                  :wIndex        => 0x00,
                                  :dataOut       => msg.pack("c*"))
        end
      end
    end
end




