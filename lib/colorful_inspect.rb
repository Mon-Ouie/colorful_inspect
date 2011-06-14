# -*- coding: utf-8 -*-

require 'pp'
require 'date'
require 'time'
require 'term/ansicolor'

module ColorfulInspect
  class << self
    attr_accessor :indent
    attr_accessor :colors
  end

  module_function
  def default_colors
    {
      :numeric   => [:blue, :bold],
      :bignum    => [:blue],
      :fixnum    => [:blue, :bold],
      :float     => [:blue, :bold],
      :rational  => [:blue],
      :true      => [:green, :bold],
      :false     => [:red, :bold],
    :nil       => [:red],
      :symbol    => [:cyan, :bold],
      :string    => [:green],
      :date      => [:black],
      :time      => [:black, :bold],
      :class     => [:yellow, :bold],
      :module    => [:yellow],
      :method    => [:magenta],
      :exception => [:red],
      :ivar      => [:cyan]
    }
  end

  def group(q, open, close, &block)
    q.group(ColorfulInspect.indent, open, "\n#{q.genspace[q.indent]}#{close}",
            &block)
  end

  def break(q)
    q.text "\n#{q.genspace[q.indent]}"
  end

  def colorize(q, type, string)
    Array(ColorfulInspect.colors[type]).inject(string) do |str, msg|
      Term::ANSIColor.send(msg, str)
    end
  end

  def method_info(method)
    args = ''

    if method.respond_to?(:parameters) && (arg_ary = method.parameters)
      arg_ary.map!.each_with_index do |(type, name), index|
        name ||= "arg#{index + 1}"

        case type
        when :req   then "#{name}"
        when :opt   then "#{name} = ?"
        when :rest  then "*#{name}"
        when :block then "&#{name}"
        else name
        end
      end

      args = '(' + arg_ary.join(', ') + ')'
    elsif method.arity == 0
      args = "()"
    elsif method.arity > 0
      n = method.arity
      args = '(' + (1..n).map { |i| "arg#{i}" }.join(", ") + ')'
    elsif method.arity < 0
      n = -method.arity
      args = '(' + (1..n).map { |i| "arg#{i}" }.join(", ") + ')'
    end

    klass = if method.respond_to? :owner
              method.owner.to_s
            elsif method.inspect =~ /Method: (.*?)#/
              $1
            end

    location = if method.respond_to? :source_location
                 file, line = method.source_location
                 "#{file}:#{line}" if file && line
               end

    [method.name.to_s, args, klass.to_s, location]
  end

  self.indent = 2
  self.colors = default_colors
end

class Array
  alias colorless_pretty_print pretty_print

  def pretty_print(q)
    return q.text("[]") if empty?

    ColorfulInspect.group(q, "[", "]") do
      index_width = (size - 1).to_s.size

      each_with_index do |elem, n|
        ColorfulInspect.break q
        q.text "[#{n.to_s.rjust(index_width)}] "
        q.pp elem
        q.text "," if n != size - 1
      end
    end
  end
end

class Hash
  alias colorless_pretty_print pretty_print

  def pretty_print(q)
    return q.text("{}") if empty?

    ColorfulInspect.group(q, "{", "}") do
      each_with_index do |(key, val), n|
        ColorfulInspect.break q
        q.pp key
        q.text " => "
        q.pp val
        q.text "," if n != size - 1
      end
    end
  end
end

[Numeric, Bignum, Fixnum, Float].each do |klass|
  type = klass.to_s.downcase.to_sym

  klass.class_eval do
    alias colorless_pretty_print pretty_print

    define_method :pretty_print do |q|
      q.text ColorfulInspect.colorize(q, type, to_s)
    end
  end
end

class Rational
  alias colorless_pretty_print pretty_print

  def pretty_print(q)
    q.text ColorfulInspect.colorize(q, :rational, "#{inspect} ≈ #{to_f}")
  end
end

[true, false, nil].each do |obj|
  obj.class.class_eval do
    alias colorless_pretty_print pretty_print

    def pretty_print(q)
      q.text ColorfulInspect.colorize(q, inspect.to_sym, inspect)
    end
  end
end

class Symbol
  alias colorless_pretty_print pretty_print

  def pretty_print(q)
    q.text ColorfulInspect.colorize(q, :symbol, inspect)
  end
end

class String
  alias colorless_pretty_print pretty_print

  def pretty_print(q)
    q.text ColorfulInspect.colorize(q, :string, inspect)
  end
end

[Date, Time].each do |klass|
  type = klass.to_s.downcase.to_sym

  klass.class_eval do
    alias colorless_pretty_print pretty_print

    define_method :pretty_print do |q|
      q.text ColorfulInspect.colorize(q, type, ctime)
    end
  end
end

class Time
  alias colorless_pretty_print pretty_print

  def pretty_print(q)
    q.text ColorfulInspect.colorize(q, :time, ctime)
  end
end

class Class
  alias colorless_pretty_print pretty_print

  def pretty_print(q)
    str = "#{inspect}#{" < #{superclass.inspect}" if superclass}"
    q.text ColorfulInspect.colorize(q, :class, str)
  end
end

class Module
  alias colorless_pretty_print pretty_print

  def pretty_print(q)
    q.text ColorfulInspect.colorize(q, :module, inspect)
  end
end

[Method, UnboundMethod].each do |klass|
  klass.class_eval do
    alias colorless_pretty_print pretty_print

    public
    def pretty_print(q)
      name, args, owner = ColorfulInspect.method_info(self)

      q.text ColorfulInspect.colorize(q, :class, owner)
      q.text '#'
      q.text ColorfulInspect.colorize(q, :method, name)
      q.text ColorfulInspect.colorize(q, :args, args)

      q.text " [unbound]" if kind_of? UnboundMethod
    end
  end
end

class Struct
  alias colorless_pretty_print pretty_print

  def pretty_print(q)
    q.text '('
    q.pp self.class
    q.text ") "

    ColorfulInspect.group(q, "{", "}") do
      each_pair.with_index do |(key, val), n|
        ColorfulInspect.break q
        q.pp key
        q.text " => "
        q.pp val
        q.text "," if n != size - 1
      end
    end
  end
end

class Exception
  alias colorless_pretty_print pretty_print

  def pretty_print(q)
    q.pp self.class
    q.text ": "
    q.text ColorfulInspect.colorize(q, :exception, message)
  end
end

class Object
  alias colorless_pretty_print pretty_print

  def pretty_print(q)
    # Check from pp.rb
    if /\(Kernel\)#/ !~ Object.instance_method(:method).bind(self).call(:inspect).inspect
      q.text self.inspect
    elsif /\(Kernel\)#/ !~ Object.instance_method(:method).bind(self).call(:to_s).inspect &&
        instance_variables.empty?
      q.text self.to_s
    else
      id = "%x" % (__id__ * 2)
      id.sub!(/\Af(?=[[:xdigit:]]{2}+\z)/, '') if id.sub!(/\A\.\./, '')

      klass = ColorfulInspect.colorize(q, :class, self.class.to_s)

      q.group(ColorfulInspect.indent, "\#<#{klass}:0x#{id}", '>') do
        q.seplist(pretty_print_instance_variables, lambda { q.text ',' }) do |ivar|
          q.breakable

          q.text ColorfulInspect.colorize(q, :ivar, ivar.to_s)
          q.text '='

          q.group(ColorfulInspect.indent) do
            q.breakable ''
            q.pp instance_variable_get(ivar)
          end
        end
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  # There is but one test to see if this works: see if the output is pretty.

  Person = Struct.new :first_name, :last_name

  pp [
      1, 2, true, 3, false, 4, nil, Rational(3, 4), 10 ** 50, Complex(3, 2),
      [], {},
      {
        :alpha => "foo",
        :beta  => "bar",
        :delta => "baz",
        [1, 3] => "some\nthing"
      },
      Date.new(2011, 10, 24),
      Time.now,
      String, Array, BasicObject, Enumerable,
      Array.instance_method(:each), 3.method(:succ), "foo".method(:pp),
      File::Stat.instance_method(:mtime), Time.method(:now),
      Person.new("John", "Smith"),
      $stdout, $stdin,
      LoadError.new("could not find a good message"),
      PrettyPrint.new
    ]
end
