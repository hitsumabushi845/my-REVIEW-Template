module ReVIEW

  module CompilerOverride
    def non_escaped_commands
      if @builder.highlight?
        # デフォルトは %i[list emlist listnum emlistnum cmd]
        # cmdをハイライトから除外してみる
        %i[list emlist listnum emlistnum]
      else
        []
      end
    end
  end

  class Compiler
    prepend CompilerOverride
  end


  module LATEXBuilderOverride
    # gem install unicode-display_width
    require 'unicode/display_width'
    require 'unicode/display_width/string_ext'

    CR = '→' # 送り出し文字。LaTeXコードも可
    ZWSCALE = 0.875 # 和文・欧文の比率。\setlength{\xkanjiskip}{\z@} しておいたほうがよさそう

    def split_line(s, n)
      # 文字列を幅nで分割
      a = []
      l = ''
      w = 0
      s.each_char do |c|
        cw = c.display_width(2) # Ambiguousを全角扱い
        cw *= ZWSCALE if cw == 2

        if w + cw > n
          a.push(l)
          l = c
          w = cw
        else
          l << c
          w += cw
        end
      end
      a.push(l)
      a
    end

    def code_line(type, line, idx, id, caption, lang)
      # _typeには'emlist'などが入ってくるので、環境に応じて分岐は可能
      n = 76
      n = 60 if @doc_status[:column]
      a = split_line(unescape(detab(line)), n)
      # インラインopはこの時点でもう展開されたものが入ってしまっているので、escapeでエスケープされてしまう…
      escape(a.join("\x01\n")).gsub("\x01", CR) + "\n"
    end

    def code_line_num(type, line, first_line_num, idx, id, caption, lang)
      n = 60
      n = 56 if @doc_status[:column]
      a = split_line(unescape(detab(line)), n)
      (idx + first_line_num).to_s.rjust(2) + ': ' + escape(a.join("\x01\n    ")).gsub("\x01", CR) + "\n"
    end

    def builder_init_file
      super
      @predefined_mint_style = %w[python ruby]
    end

    def cmd(lines, caption = nil, lang = nil)
      # cmdについてはハイライトなし版のみを使う
      blank
      common_code_block(nil, lines, 'reviewcmd', caption, lang) { |line, idx| code_line('cmd', line, idx, nil, caption, lang) }
    end

    # リスト環境をcommon_minted_codeに任せる。言語のデフォルトにshを設定しておく
    def emlist(lines, caption = nil, lang = 'sh')
      common_minted_code(nil, 'emlist', nil, lines, caption, lang)
    end

    def emlistnum(lines, caption = nil, lang = 'sh')
      common_minted_code(nil, 'emlist', line_num, lines, caption, lang)
    end

    def list(lines, id, caption, lang = 'sh')
      common_minted_code(id, 'list', nil, lines, caption, lang)
    end

    def listnum(lines, id, caption, lang = 'sh')
      common_minted_code(id, 'list', line_num, lines, caption, lang)
    end

    def common_minted_code(id, command, lineno, lines, caption, lang)
      blank
      puts '\\begin{reviewlistblock}'
      if caption.present?
        if command =~ /emlist/ || command =~ /cmd/ || command =~ /source/
          captionstr = macro('review' + command + 'caption', compile_inline(caption))
        else
          begin
            if get_chap.nil?
              captionstr = macro('reviewlistcaption', "#{I18n.t('list')}#{I18n.t('format_number_header_without_chapter', [@chapter.list(id).number])}#{I18n.t('caption_prefix')}#{compile_inline(caption)}")
            else
              captionstr = macro('reviewlistcaption', "#{I18n.t('list')}#{I18n.t('format_number_header', [get_chap, @chapter.list(id).number])}#{I18n.t('caption_prefix')}#{compile_inline(caption)}")
            end
          rescue KeyError
            error "no such list: #{id}"
          end
        end
      end
      @doc_status[:caption] = nil

      if caption_top?('list') && captionstr
        puts captionstr
      end

      body = lines.inject('') { |i, j| i + detab(j) + "\n" }
      args = 'breaklines=true'
      if lineno
        args = "linenos=true,firstnumber=#{lineno},breaklines=true,frame=leftline,numbersep=5pt"
      end
      puts %Q(\\begin{minted}[#{args}]{#{lang}})
      print body
      puts %Q(\\end{minted})

      if !caption_top?('list') && captionstr
        puts captionstr
      end

      puts '\\end{reviewlistblock}'
      blank
    end
  end

  class LATEXBuilder
    prepend LATEXBuilderOverride
  end
end
