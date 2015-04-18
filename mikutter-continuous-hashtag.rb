# -*- coding: utf-8 -*-

Plugin.create :continuous_hashtag do
  window = nil

  on_boot do |service|
    UserConfig[:continuos_hashtag_space_before] = false if UserConfig[:continuos_hashtag_space_before].nil?
    UserConfig[:continuos_hashtag_space_after] = false if UserConfig[:continuos_hashtag_space_after].nil?
    UserConfig[:continuos_hashtag_cr_before] = true if UserConfig[:continuos_hashtag_cr_before].nil?
    UserConfig[:continuos_hashtag_cr_after] = false if UserConfig[:continuos_hashtag_cr_after].nil?
    UserConfig[:continuos_hashtag_cursor_position] = 0 if UserConfig[:continuos_hashtag_cursor_position].nil?
  end


  def get_all_widgets(root, klass)
    proc = lambda { |widget|
      result = []

      begin
        widget.each_forall { |child|
          if child.is_a?(klass)
            result << child
          end

          if child.is_a?(::Gtk::Container)
            result += proc.call(child)
          end
        }
      rescue => e
      end

      result
    }

    proc.call(root)
  end


  on_window_created do |i_window|
    begin
      # メインウインドウを取得
      window_tmp = Plugin.filtering(:gui_get_gtk_widget,i_window)

      if (window_tmp == nil) || (window_tmp[0] == nil) then
        next
      end

      window = window_tmp[0]

    rescue => e
      puts e
      puts e.backtrace
    end
  end


  filter_posted do |service, messages|
    begin
      hashtags = messages[0][:entities][:hashtags].map { |hash| hash[:text]}

      if hashtags.length != 0
        postbox = get_all_widgets(window, ::Gtk::PostBox)[0]

        before = ""

        if UserConfig[:continuos_hashtag_cr_before]
          before += "\n"
        end

        if UserConfig[:continuos_hashtag_space_before]
          before += " "
        end

        after = ""

        if UserConfig[:continuos_hashtag_space_after]
          after += " "
        end

        if UserConfig[:continuos_hashtag_cr_after]
          after += "\n"
        end

        postbox.post.buffer.text = before + hashtags.map { |a| "\##{a}" }.join(" ") + after

        if UserConfig[:continuos_hashtag_cursor_position] == 0
          postbox.post.move_cursor(Gtk::MOVEMENT_BUFFER_ENDS, -1, false)
        else
          postbox.post.move_cursor(Gtk::MOVEMENT_BUFFER_ENDS, 0, false)
        end
      end
    rescue => e
      puts e
      puts e.backtrace
    end

    [service, messages]
  end


  settings "実況モード" do
    begin
      boolean("ハッシュタグの前にスペースを挿入", :continuos_hashtag_space_before)
      boolean("ハッシュタグの後にスペースを挿入", :continuos_hashtag_space_after)
      boolean("ハッシュタグの前に改行を挿入", :continuos_hashtag_cr_before)
      boolean("ハッシュタグの後に改行を挿入", :continuos_hashtag_cr_after)
      select("カーソル位置", :continuos_hashtag_cursor_position, { 0 => "先頭", 1 => "末尾" })
    rescue => e
      puts e
      puts e.backtrace
    end
  end

end

