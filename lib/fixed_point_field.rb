# The MIT License
# 
# Copyright (c) 2007 Todd Willey <todd@lvoltaiccommerce.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# Fixed Point Field specifies that a field that is accessed like a float from
# a rails script should be stored as an integer in the database.  This is only
# practical when the field always has a fixed number of digits after the
# decimal place, like how US Dollars have 2 digits of cents after the decimal.
# More information and examples are available in the README.
module FixedPointField

  # When the module is included, in addition to adding the methods to instances
  # of the class, we need to add methods to the class object, do this
  # with extend.
  def self.included kls
    kls.send :extend, ClassMethods
  end

  # Set a fixed point column to the specificed value (fixed).  This
  # is wrapped behind a conversion for the default assignment operator,
  # such that if you had called:
  # <code>fixed_point_field :price</code>
  # the method price= would convert and then call this function.
  def set_fixed_point(column_name, value)
    write_attribute(column_name, value)
  end

  # Set a column using a floating point column.  This calls
  # set_fixed_point after it has up-scaled the value to the specified
  # number of digits.  By default the width is 2 and base is 10, to
  # work with USD currency.
  # If you had called:
  # <code>fixed_point_field :price</code>
  # the method price= would be a direct call to this function.
  def set_floating_point(column_name, value, width = 2, base = 10)
    return if value == ''
    set_fixed_point(column_name, (value.to_f * (base**width)).round)
  end

  # Retrieve the raw value of the field, which will be a Fixnum.
  # This is wrapped behind the default getter, so it is fetched with this
  # function, then down-converted and returned.
  def read_fixed_point(column_name)
    read_attribute(column_name)
  end

  # Reads the fixed point version and converts.  Will return nil if the column
  # value is nil.  If you had called:
  # <code>fixed_point_field :price</code>
  # the method price would be a direct call to this function.
  def read_floating_point(column_name, width = 2, base = 10)
    (rv = read_fixed_point(column_name)) ? (rv.to_f / (base**width)) : nil
  end

  module FixedPointField::ClassMethods

    # Calling this in an active record class will make getters / setters
    # available for in integer field that return / accept values that are
    # floating point.  It will convert them to integer values by up-scaling
    # the number by a certain number of decimal places.  This is most useful
    # for working with money, when the values can be stored as cents, but
    # will most often be working with dollars, which always has two places
    # after the decimal reserved for cents.
    #
    # Takes any number of field names to be converted, and an optional
    # hash as the last argument.  The hash can have keys of :width, which
    # is the number of places beyond the decimal to use (default 2), and
    # :base, which is the number system to use (default 10 [decimal]).
    #
    # This for a field named my_field, this will generate the methods
    #   * my_field - returns the value as a float
    #   * my_field_fixed - returns the value as it is stored (Fixnum)
    #   * my_field= - takes a floating point number and scales it appropriately
    #   * my_field_fixed= - direct setter for fixed point number
    def fixed_point_field *fields
      opts = (fields.pop if fields.last.is_a?(Hash)) || {}
      opts[:width] ||= 2
      opts[:base] ||= 10
      fields.each do |field|
        read_fixed_method = "#{field}_fixed"
        read_float_method = "#{field}"
        set_float_method = "#{field}="
        set_fixed_method = "#{field}_fixed="

        define_method(read_fixed_method) do
          read_fixed_point(field)
        end

        define_method(read_float_method) do
          read_floating_point(field, opts[:width], opts[:base])
        end

        define_method(set_float_method) do |value|
          set_floating_point(field, value, opts[:width], opts[:base])
        end

        define_method(set_fixed_method) do |value|
          set_fixed_point(field, value)
        end

      end
    end
  end

end
