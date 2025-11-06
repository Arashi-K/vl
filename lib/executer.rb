module Executer
  class ParseError < StandardError; end

  class << self
    def execute(code, argv, working_dir)
      lines = str_ary_compact(code.split("\n"))
      pipe = []
      register = {}
      lines.each do |line|
        tokens = str_ary_compact(line.split(/\s+/))
        pipe, _ = take(tokens, pipe, register, argv, working_dir)
      end
      pipe
    end

    def take(tokens, pipe, register, argv, working_dir)
      return [[], []] if tokens.length == 0

      action, *tokens = tokens
      return case must_str(action)
      when 'vl'
        a, *tokens = tokens
        res = must_str(a)
        return [[res], tokens]
      when 'vs'
        k, tokens = take(tokens, pipe, register, argv, working_dir)
        v, tokens = take(tokens, pipe, register, argv, working_dir)
        key = must_str(must_ary(k, 1)[0])
        val = must_str(must_ary(v, 1)[0])
        register[key] = val
        return [[val], tokens]
      when 'vg'
        k, tokens = take(tokens, pipe, register, argv, working_dir)
        key = must_str(must_ary(k, 1)[0])
        res = must_str(register[key])
        return [[res], tokens]
      when 'vm'
        count, *tokens = tokens
        res = []
        must_int(count, min: 1).times do
          r, tokens = take(tokens, pipe, register, argv, working_dir)
          res.concat must_ary(r, 1)
        end
        return [res, tokens]
      when 'va'
        num, *tokens = tokens
        res = must_str(argv[must_int(num, min: 1) - 1])
        return [[res], tokens]
      when 'vp'
        num, *tokens = tokens
        res = must_str(pipe[must_int(num, min: 1) - 1])
        return [[res], tokens]
      when 'sj'
        a, tokens = take(tokens, pipe, register, argv, working_dir)
        b, tokens = take(tokens, pipe, register, argv, working_dir)
        res = must_ary(a, 1).concat(must_ary(b, 1)).map(&method(:must_str)).join
        return [[res], tokens]
      when 'na'
        a, tokens = take(tokens, pipe, register, argv, working_dir)
        b, tokens = take(tokens, pipe, register, argv, working_dir)
        res = must_num(must_ary(a, 1)[0]) + must_num(must_ary(b, 1)[0])
        return [[res.to_s], tokens]
      when 'ns'
        a, tokens = take(tokens, pipe, register, argv, working_dir)
        b, tokens = take(tokens, pipe, register, argv, working_dir)
        res = must_num(must_ary(a, 1)[0]) - must_num(must_ary(b, 1)[0])
        return [[res.to_s], tokens]
      when 'nm'
        a, tokens = take(tokens, pipe, register, argv, working_dir)
        b, tokens = take(tokens, pipe, register, argv, working_dir)
        res = must_num(must_ary(a, 1)[0]) * must_num(must_ary(b, 1)[0])
        return [[res.to_s], tokens]
      when 'nd'
        a, tokens = take(tokens, pipe, register, argv, working_dir)
        b, tokens = take(tokens, pipe, register, argv, working_dir)
        res = must_num(must_ary(a, 1)[0]) / must_num(must_ary(b, 1)[0])
        return [[res.to_s], tokens]
      when 'fr'
        f, tokens = take(tokens, pipe, register, argv, working_dir)
        path = must_file("#{working_dir}/#{must_ary(f, 1)[0]}")
        code = File.read(path)
        count, *tokens = tokens
        as = []
        must_int(count, min: 0).times do
          a, tokens = take(tokens, pipe, register, argv, working_dir)
          as.concat must_ary(a, 1)
        end
        working_dir = File.dirname(path)
        res = execute(code, as, working_dir)
        return [res, tokens]
      else raise_parse_error()
      end
    end

    private
    def raise_parse_error
      raise ParseError
    end

    def must_str(val)
      raise_parse_error() unless val.is_a?(String)
      val
    end

    def must_int(val, min: nil, max: nil)
      must_str(val)
      raise_parse_error() unless val.to_i.to_s == val
      raise_parse_error() unless min.nil? || min <= val.to_i
      raise_parse_error() unless max.nil? || val.to_i <= max
      val.to_i
    end

    def must_flt(val, min: nil, max: nil)
      must_str(val)
      raise_parse_error() unless val.to_f.to_s == val
      raise_parse_error() unless min.nil? || min <= val.to_f
      raise_parse_error() unless max.nil? || val.to_f <= max
      val.to_f
    end

    def must_num(val, min: nil, max: nil)
      must_str(val)
      return must_int(val, min: min, max: max) if val.to_i.to_s == val
      return must_flt(val, min: min, max: max) if val.to_f.to_s == val
      raise_parse_error()
    end

    def must_ary(val, len)
      raise_parse_error() unless val.is_a?(Array)
      raise_parse_error() unless val.length == len
      val
    end

    def must_file(val)
      must_str(val)
      raise_parse_error() unless File.exist?(val)
      val
    end

    def str_ary_compact(ary)
      ary.map(&:strip).filter{ |s| !s.empty?}
    end
  end
end
