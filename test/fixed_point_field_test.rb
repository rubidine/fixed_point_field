begin
    require 'active_record'
rescue LoadError
    require 'rubygems'
    require 'active_record'
end

$: << File.join(File.dirname(__FILE__), '..', 'lib')
require File.join(File.dirname(__FILE__), '..', 'init.rb')

begin
  require 'mocha'
rescue LoadError
  raise "Please install the mocha gem to test fixed_point_column."
end

require 'test/unit'

class FixedPointFieldTest < Test::Unit::TestCase

  class Sentinel < RuntimeError
  end

  class TestRecord < ActiveRecord::Base
    def self.columns
      [
        ActiveRecord::ConnectionAdapters::Column.new(
          'a', #name
          nil, #default
          'int(11)', # sql type
          true #null
        ),
        ActiveRecord::ConnectionAdapters::Column.new(
          'b', #name
          nil, #default
          'int(11)', # sql type
          true #null
        )
      ]
    end
  end

  def test_mixin_works
    TestRecord.send(:fixed_point_field, :a)
    instance = TestRecord.new

    assert instance.respond_to?(:set_fixed_point)
    assert instance.respond_to?(:set_floating_point)
    assert instance.respond_to?(:read_fixed_point)
    assert instance.respond_to?(:read_floating_point)

    assert instance.respond_to?(:a_fixed)
    assert instance.respond_to?(:a)
    assert instance.respond_to?(:a_fixed=)
    assert instance.respond_to?(:a=)
  end

  def test_sane_defaults
    TestRecord.send(:fixed_point_field, :a)
    instance = TestRecord.new

    # make sure it works before the stub
    instance.a = 10.3

    # 2, 10 are our default width and base
    instance.stubs(:set_floating_point).with(:a, 10.3, 2, 10).raises(Sentinel)
    assert_raises(Sentinel) do
      instance.a = 10.3
    end
  end

  def test_mixin_works_with_options
    TestRecord.send(:fixed_point_field, :a, {:width => 1})
    instance = TestRecord.new

    assert instance.respond_to?(:set_fixed_point)
    assert instance.respond_to?(:set_floating_point)
    assert instance.respond_to?(:read_fixed_point)
    assert instance.respond_to?(:read_floating_point)

    assert instance.respond_to?(:a_fixed)
    assert instance.respond_to?(:a)
    assert instance.respond_to?(:a_fixed=)
    assert instance.respond_to?(:a=)
  end

  def test_options_are_followed
    TestRecord.send(:fixed_point_field, :a, {:width => 1})
    instance = TestRecord.new

    # make sure it works before the stub
    instance.a = 10.3

    # third argument = width
    instance.stubs(:set_floating_point).with(:a, 10.3, 1, 10).raises(Sentinel)
    assert_raises(Sentinel) do
      instance.a = 10.3
    end

    # make sure it works before the stub
    instance.a

    # second argument = width
    instance.stubs(:read_floating_point).with(:a, 1, 10).raises(Sentinel)
    assert_raises(Sentinel) do
      instance.a
    end
  end

  def test_set_float
    TestRecord.send(:fixed_point_field, :a)
    instance = TestRecord.new
    instance.a = 10.3
    assert_equal 1030, instance.send(:read_attribute, :a)
  end

  def test_set_fixed
    TestRecord.send(:fixed_point_field, :a)
    instance = TestRecord.new
    instance.a_fixed = 103
    assert_equal 103, instance.send(:read_attribute, :a)
  end

  def test_read_float
    TestRecord.send(:fixed_point_field, :a)
    instance = TestRecord.new
    instance.send(:write_attribute, :a, 103)
    assert_equal 1.03, instance.a
  end

  def test_read_fixed
    TestRecord.send(:fixed_point_field, :a)
    instance = TestRecord.new
    instance.send(:write_attribute, :a, 103)
    assert_equal 103, instance.a_fixed
  end

  def test_write_and_read_paring
    TestRecord.send(:fixed_point_field, :a)
    instance = TestRecord.new

    instance.a = 10.3
    assert_equal 10.3, instance.a
    assert_equal 1030, instance.a_fixed

    instance.a_fixed = 1310
    assert_equal 13.10, instance.a
    assert_equal 1310, instance.a_fixed
  end

  def test_multiple_fields_mixin
    TestRecord.send(:fixed_point_field, :a, :b)
    instance = TestRecord.new

    assert instance.respond_to?(:set_fixed_point)
    assert instance.respond_to?(:set_floating_point)
    assert instance.respond_to?(:read_fixed_point)
    assert instance.respond_to?(:read_floating_point)

    assert instance.respond_to?(:a_fixed)
    assert instance.respond_to?(:a)
    assert instance.respond_to?(:a_fixed=)
    assert instance.respond_to?(:a=)

    assert instance.respond_to?(:b_fixed)
    assert instance.respond_to?(:b)
    assert instance.respond_to?(:b_fixed=)
    assert instance.respond_to?(:b=)
  end

  def test_multiple_fields_read_write_pairing_without_collision
    TestRecord.send(:fixed_point_field, :a, :b)
    instance = TestRecord.new

    instance.a = 10.3
    instance.b = 1.1
    assert_equal 10.3, instance.a
    assert_equal 1030, instance.a_fixed
    assert_equal 1.1, instance.b
    assert_equal 110, instance.b_fixed

    instance.a_fixed = 1310
    instance.b_fixed = 570
    assert_equal 13.10, instance.a
    assert_equal 1310, instance.a_fixed
    assert_equal 5.70, instance.b
    assert_equal 570, instance.b_fixed
  end

  def test_multiple_fields_mixin_with_options
    TestRecord.send(:fixed_point_field, :a, :b, {:width => 1})
    instance = TestRecord.new

    assert instance.respond_to?(:set_fixed_point)
    assert instance.respond_to?(:set_floating_point)
    assert instance.respond_to?(:read_fixed_point)
    assert instance.respond_to?(:read_floating_point)

    assert instance.respond_to?(:a_fixed)
    assert instance.respond_to?(:a)
    assert instance.respond_to?(:a_fixed=)
    assert instance.respond_to?(:a=)

    assert instance.respond_to?(:b_fixed)
    assert instance.respond_to?(:b)
    assert instance.respond_to?(:b_fixed=)
    assert instance.respond_to?(:b=)
  end

  def test_base_twenty
    TestRecord.send(:fixed_point_field, :a, :b, {:base => 20})
    instance = TestRecord.new

    instance.a = 10.3
    assert_equal (10.3 * (20 ** 2)), instance.send(:read_attribute, :a)

    # make sure it loads back okay as well
    assert_equal 10.3, instance.a
  end

end
