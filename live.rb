require 'gosu'

class LiveWindow < Gosu::Window
  def initialize
    #http://www.sengpielaudio.com/calculator-bpmtempotime.htm
    #60000 / 90 = 667
    @bpm = 80 
    @fps = 60000.0 / @bpm
    one_minute_millis = 60 * 1000
    sample_bars = 4
    @sample_millis = one_minute_millis * sample_bars / @bpm
    
    opt = { width: 480, height: 640, fullscreen: false, update_interval: @fps }
    super opt[:width], opt[:height], opt[:fullscreen], opt[:update_interval]
    self.caption = "Broken Slide Live Sampler"
    
    @font = Gosu::Font.new(42)
    
    @beat = 0
    @bar = 1
    @frames = 0
    @milli_last = 0
    
    sample_files = [
      './media/A1.wav',
      './media/A2.wav',
      './media/A3.wav',
      './media/A4.wav'
    ]
    @samples = sample_files.map{|sf| Gosu::Sample.new sf}
    @sample_instances = [nil] * @samples.size
    @current_sample = 0
    @log = ""
    
    @paused = true
  end

  def update
    @milli_now = Gosu::milliseconds()
    @milli_diff = Gosu::milliseconds() - @milli_last
    @milli_last = @milli_now
    
    @frames += 1
    
    if !@paused
      @beat += 1
      if @beat > 4
        @beat = 1
        @bar += 1
      end
      
      if @beat == 1
        @sample_instances[@current_sample] = @samples[@current_sample].play(1, 1, false)
      end
    end
  end

  def draw
    interline = 60
    top = 10
    text = "bpm #{@bpm}"
    @font.draw(text, 10, top+(interline*1), 3, 1.0, 1.0, 0xff_ffff00)
    text = "bar ##{@bar}"
    @font.draw(text, 10, top+(interline*2), 3, 1.0, 1.0, 0xff_ffff00)
    text = "beat ##{@beat}"
    @font.draw(text, 10, top+(interline*3), 3, 1.0, 1.0, 0xff_ffff00)
    text = "frames ##{@frames}"
    @font.draw(text, 10, top+(interline*4), 3, 1.0, 1.0, 0xff_ffff00)
    text = "milli_now: #{@milli_now}"
    @font.draw(text, 10, top+(interline*5), 3, 1.0, 1.0, 0xff_ffff00)
    
    text = "milli_diff: #{@milli_diff}"
    @font.draw(text, 10, top+(interline*6), 3, 1.0, 1.0, 0xff_ffff00)
    
    text = "current sample #{@current_sample + 1}"
    @font.draw(text, 10, top+(interline*7), 3, 1.0, 1.0, 0xff_ffff00)
    
    text = "paused: #{@paused}"
    @font.draw(text, 10, top+(interline*8), 3, 1.0, 1.0, 0xff_ffff00)
    
    @font.draw(@log, 10, top+(interline*9), 3, 1.0, 1.0, 0xff_ffff00)
    
    text = @sample_instances.map{|si| (si && si.playing?)}
    @font.draw(text, 10, top+(interline*10), 3, 1.0, 1.0, 0xff_ffff00)
  end
  
  def button_down(id)
    @log = "button_down(#{id})"
    case id
      when 30#1
        @current_sample = 0
      when 31#2
        @current_sample = 1
      when 32#3
        @current_sample = 2
      when 33#4
        @current_sample = 3
      when 44#space
        if @paused
          stop_other(@current_sample)
          if @sample_instances[@current_sample] && @sample_instances[@current_sample].paused?
            @sample_instances[@current_sample].resume
          else
            @sample_instances[@current_sample] = @samples[@current_sample].play(1, 1, false)
          end
          @paused = false
        else
          if @sample_instances[@current_sample] && @sample_instances[@current_sample].playing?
            @sample_instances[@current_sample].pause
          end
          @paused = true
        end
    end
  end
  
  def stop_other(index)
    @sample_instances.each_with_index do |s, i|
      s.stop if (i != index && s)
    end
  end
end

window = LiveWindow.new
window.show
