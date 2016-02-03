require 'json'

class Flash
  attr_accessor :now

  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    cookies = req.cookies
    f_cookie = cookies["_rails_lite_app"]
    if f_cookie
      @now_flash = JSON.parse(f_cookie)
    else
      @now_flash = {}
    end
    @pending_flash = {}
    @discard = {}
  end

  def clear
    @pending_flash = {}
  end

  def delete(k)
    @pending_flash.delete(k.to_s)
  end

  def discard(k = nil)
    if k.to_s = nil
      @pending_flash.each_key do |k|
        @discard[k.to_s] = true
      end
    else
      @discard[k.to_s] = true
    end
  end

  def empty?
    @pending_flash.empty?
  end

  def keep(key_arr = nil)
    if key_arr
      key_arr.each do |k|
        @pending_flash[k.to_s] = @now_flash[k.to_s]
      end
    else
      @pending_flash.merge(@now_flash)
    end
  end

  def key?(name)
    @pending_flash.key? name.to_s
  end

  def keys
    @pending_flash.keys
  end

  def [](key)
    @pending_flash[key.to_s]
  end

  def []=(key, val)
    @pending_flash[key.to_s] = val
  end

  def now.alert
    @now_flash[:alert]
  end

  def now.alert=(alert)
    @now_flash[:alert] = alert
  end

  def now.notice
    @now_flash[:notice]
  end

  def now.notice=(notice)
    @now_flash[:notice] = notice
  end

  def notice
    @pending_flash[:notice]
  end

  def notice=(notice)
    @pending_flash[:notice] = notice
  end

  def alert
    @pending_flash[:alert]
  end

  def alert=(alert)
    @pending_flash[:alert] = alert
  end

  def to_hash
    @pending_flash.dup
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    if @pending_flash
      @pending_flash.each_key do |k|
        if @discard[k.to_s]
          @pending_flash.delete(k.to_s)
        end
      end
      res.set_cookie("_rails_lite_app", @pending_flash.to_json)
    else
      res.set_cookie("_rails_lite_app", {}.to_json)
    end
  end
end
