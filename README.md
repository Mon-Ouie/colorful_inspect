# What is it?

PP is a library from stdlib that allows to print objects with a nice formatting,
using PrettyPrint from stdlib. It is quite easy to customize it.

AwesomePrint is a gem to print objects using fancy colors. The output is nice,
but it's not as extensible as PP/PrettyPrint and it monkey patches several
classes from core (e.g. Object#methods, String to add colors, …). It also won't
use the pretty_print methods from classes that implement it.

ColorfulInspect is only changing the pretty_print method from several classes to
add colored formatting.

# Installation

    gem install colorful_inspect

# Example

Just require it and use pp as usual:

```ruby
    require 'colorful_inspect'

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
        Person.new("John", "Smith"),
        $stdout, $stdin,
        LoadError.new("could not find a good message"),
        PrettyPrint.new
      ]
```

And here's the output (without the colors):

    [
      [ 0] 1,
      [ 1] 2,
      [ 2] true,
      [ 3] 3,
      [ 4] false,
      [ 5] 4,
      [ 6] nil,
      [ 7] (3/4) ≈ 0.75,
      [ 8] 100000000000000000000000000000000000000000000000000,
      [ 9] 3+2i,
      [10] [],
      [11] {},
      [12] {
        :alpha => "foo",
        :beta => "bar",
        :delta => "baz",
        [
          [0] 1,
          [1] 3
        ] => "some\nthing"
      },
      [13] Mon Oct 24 00:00:00 2011,
      [14] Fri Jun 10 01:43:18 2011,
      [15] String < Object,
      [16] Array < Object,
      [17] BasicObject,
      [18] Enumerable,
      [19] Array#each() [unbound],
      [20] Fixnum#succ(),
      [21] Kernel#pp(*objs),
      [22] (Person < Struct) {
        :first_name => "John",
        :last_name => "Smith"
      },
      [23] #<IO:<STDOUT>>,
      [24] #<IO:<STDIN>>,
      [25] LoadError < ScriptError: could not find a good message,
      [26] #<PrettyPrint:0x1b1db58
        @buffer=[],
        @buffer_width=0,
        @genspace=
          #<Proc:0x00000001b1dab8@/usr/lib/ruby/1.9.1/prettyprint.rb:82 (lambda)>,
        @group_queue=
          #<PrettyPrint::GroupQueue:0x1b1d9f0
            @queue=
              [
                [0] [
                  [0] #<PrettyPrint::Group:0x1b1da68
                    @break=false,
                    @breakables=[],
                    @depth=0>
                ]
              ]>,
        @group_stack=
          [
            [0] #<PrettyPrint::Group:0x1b1da68
              @break=false,
              @breakables=[],
              @depth=0>
          ],
        @indent=0,
        @maxwidth=79,
        @newline="\n",
        @output="",
        @output_width=0>
    ]


You can change the indentation as well as the used colors:

```ruby
ColorfulInspect.indent = 4 # defaults to two

# pp ColorfulInspect.colors to see available colors :)
ColorfulInspect.colors[:nil] = :red
```

Colors can also be disabled and reactivated:

```ruby
ColorfulInspect.colors.clear
ColorfulInspect.colors = ColorfulInspect.default_colors
```
