$: << File.dirname($0) << File.join(File.dirname($0), "..")
require 'rubicon'

$m0 = ZModule.nesting
unless defined? ExpectedException
  Version.less_than("1.7") do
    ExpectedException = NameError
  end
  Version.greater_or_equal("1.7") do
    ExpectedException = NoMethodError
  end 
end


class TestZModule < Rubicon::TestCase

  # Support stuff

  module Mixin
    MIXIN = 1
    def mixin
    end
  end

  module User
    USER = 2
    include Mixin
    def user
    end
  end

  module Other
    def other
    end
  end

  class AClass
    def AClass.cm1
      "cm1"
    end
    def AClass.cm2
      cm1 + "cm2" + cm3
    end
    def AClass.cm3
      "cm3"
    end
    
    private_class_method :cm1, "cm3"

    def aClass
    end

    def aClass1
    end

    def aClass2
    end

    private :aClass1
    protected :aClass2
  end

  class BClass < AClass
    def bClass1
    end

    private

    def bClass2
    end

    protected
    def bClass3
    end
  end

  MyClass = AClass.clone
  class MyClass
    public_class_method :cm1
  end

  # -----------------------------------------------------------

  def test_CMP # '<=>'
    assert_equal( 0, Mixin <=> Mixin)
    assert_equal(-1, User <=> Mixin)
    assert_equal( 1, Mixin <=> User)
    Version.less_than("1.7") do
      assert_equal(1, Mixin <=> User)
    end

    assert_equal( 0, Object <=> Object)
    assert_equal(-1, String <=> Object)
    assert_equal( 1, Object <=> String)
  end

  def test_GE # '>='
    assert(Mixin >= User)
    assert(Mixin >= Mixin)
    assert(!(User >= Mixin))

    assert(Object >= String)
    assert(String >= String)
    assert(!(String >= Object))
  end

  def test_GT # '>'
    assert(Mixin   > User)
    assert(!(Mixin > Mixin))
    assert(!(User  > Mixin))

    assert(Object > String)
    assert(!(String > String))
    assert(!(String > Object))
  end

  def test_LE # '<='
    assert(User <= Mixin)
    assert(Mixin <= Mixin)
    assert(!(Mixin <= User))

    assert(String <= Object)
    assert(String <= String)
    assert(!(Object <= String))
  end

  def test_LT # '<'
    assert(User < Mixin)
    assert(!(Mixin < Mixin))
    assert(!(Mixin < User))

    assert(String < Object)
    assert(!(String < String))
    assert(!(Object < String))
  end

  def test_VERY_EQUAL # '==='
    assert(Object === self)
    assert(Rubicon::TestCase === self)
    assert(TestModule === self)
    assert(!(String === self))
  end

  def test_ancestors
    assert_equal([User, Mixin],      User.ancestors)
    assert_equal([Mixin],            Mixin.ancestors)

    assert_equal([Object, Kernel],   Object.ancestors)
    assert_equal([String, 
                   Enumerable, 
                   Comparable,
                   Object, Kernel],  String.ancestors)
  end

  def test_class_eval
    Other.class_eval("CLASS_EVAL = 1")
    assert_equal(1, Other::CLASS_EVAL)
    assert(Other.constants.include?("CLASS_EVAL"))
  end

  def test_const_defined?
    assert(Math.const_defined?(:PI))
    assert(Math.const_defined?("PI"))
    assert(!Math.const_defined?(:IP))
    assert(!Math.const_defined?("IP"))
  end

  def test_const_get
    assert_equal(Math::PI, Math.const_get("PI"))
    assert_equal(Math::PI, Math.const_get(:PI))
  end

  def test_const_set
    assert(!Other.const_defined?(:KOALA))
    Other.const_set(:KOALA, 99)
    assert(Other.const_defined?(:KOALA))
    assert_equal(99, Other::KOALA)
    Other.const_set("WOMBAT", "Hi")
    assert_equal("Hi", Other::WOMBAT)
  end

  def test_constants
    assert_equal(["MIXIN"], Mixin.constants)
    assert_equal(["MIXIN", "USER"], User.constants.sort)
  end

  def test_included_modules
    assert_equal([], Mixin.included_modules)
    assert_equal([Mixin], User.included_modules)
    assert_equal([Kernel], Object.included_modules)
    assert_equal([Enumerable, Comparable, Kernel], String.included_modules)
  end

  def test_instance_methods
    assert_equal(["user" ], User.instance_methods)
    assert_equal(["user", "mixin"], User.instance_methods(true))
    assert_equal(["mixin"], Mixin.instance_methods)
    assert_equal(["mixin"], Mixin.instance_methods(true))
    assert_equal(["aClass"], AClass.instance_methods)
    assert_equal(["aClass"], AClass.instance_methods(true) - 
                             Object.instance_methods(true))
  end

  def test_method_defined?
    assert(!User.method_defined?(:wombat))
    assert(User.method_defined?(:user))
    assert(User.method_defined?(:mixin))
    assert(!User.method_defined?("wombat"))
    assert(User.method_defined?("user"))
    assert(User.method_defined?("mixin"))
  end

  def test_module_eval
    User.module_eval("MODULE_EVAL = 1")
    assert_equal(1, User::MODULE_EVAL)
    assert(User.constants.include?("MODULE_EVAL"))
    User.instance_eval("remove_const(:MODULE_EVAL)")
    assert(!User.constants.include?("MODULE_EVAL"))
  end

  def test_name
    assert_equal("Fixnum", Fixnum.name)
    assert_equal("TestModule::Mixin",  Mixin.name)
    assert_equal("TestModule::User",   User.name)
  end

  def test_private_class_method
    assert_exception(ExpectedException) { AClass.cm1 }
    assert_exception(ExpectedException) { AClass.cm3 }
    assert_equal("cm1cm2cm3", AClass.cm2)
  end

  def test_private_instance_methods
    assert_equal(["aClass1"], AClass.private_instance_methods)
    assert_equal(["bClass2"], BClass.private_instance_methods)
    assert_equal(["bClass2", "aClass1"],
                 BClass.private_instance_methods(true) -
                 Object.private_instance_methods(true))
  end

  def test_protected_instance_methods
    assert_equal(["aClass2"], AClass.protected_instance_methods)
    assert_equal(["bClass3"], BClass.protected_instance_methods)
    assert_equal(["bClass3", "aClass2"],
                 BClass.protected_instance_methods(true) -
                 Object.protected_instance_methods(true))
  end

  def test_public_class_method
    assert_equal("cm1",       MyClass.cm1)
    assert_equal("cm1cm2cm3", MyClass.cm2)
    assert_exception(ExpectedException) { eval "MyClass.cm3" }
  end

  def test_public_instance_methods
    assert_equal(["aClass"],  AClass.public_instance_methods)
    assert_equal(["bClass1"], BClass.public_instance_methods)
  end

  def test_s_constants
    c1 = ZModule.constants
    Object.module_eval "WALTER = 99"
    c2 = ZModule.constants
    assert_equal(["WALTER"], c2 - c1)
  end

  module M1
    $m1 = ZModule.nesting
    module M2
      $m2 = ZModule.nesting
    end
  end

  def test_s_nesting
    assert_equal([],                               $m0)
    assert_equal([TestModule::M1, TestModule],     $m1)
    assert_equal([TestModule::M1::M2,
                  TestModule::M1, TestModule],     $m2)
  end

  def test_s_new
    m = ZModule.new
    assert_instance_of(ZModule, m)
  end

end

Rubicon::handleTests(TestModule) if $0 == __FILE__
