require 'test_helper'

describe Funkiset do
  subject { Funkiset.new(foo: 4, bar: 2, baz: 0) }
  let(:other){ Funkiset.new(foo: -3, qux: 2) }

  describe "#initialize" do
    it "must accept a hash" do
      subject.keys.must_equal([:foo, :bar])
    end
    it "must accept no arguments" do
      set = Funkiset.new
      set.keys.must_equal([])
    end
    it "must accept an Array" do
      set = Funkiset.new([:a, :b, :c, :a, :b])
      set.keys.must_equal([:a, :b, :c])
    end
    it "must accept a Funkiset" do
      set = Funkiset.new(subject)
      set.keys.must_equal([:foo, :bar])
    end
  end

  describe "::[]" do
    it "must create a new set" do
      set = Funkiset[:a, :b, :b, :c]
      set.keys.must_equal([:a, :b, :c])
    end
  end

  describe "counters" do
    it "must be an Enumerable" do
      subject.counters.must_be_kind_of(Enumerable)
    end
    it "should delete keys with zero counts" do
      subject.counters.keys.must_equal([:foo, :bar])
    end
  end

  describe "#[]" do
    it "must find existing keys and return count" do
      subject[:foo].must_equal(4)
      subject[:bar].must_equal(2)
    end
    it "must return nil for missing keys" do
      subject[:qux].must_be_nil
    end
    it "must return nil for keys with zero counts" do
      subject[:bax].must_be_nil
    end
  end

  describe "#[]=" do
    it "must set count for exisiting keys" do
      subject[:foo].must_equal(4)
      subject[:foo] = -1
      subject[:foo].must_equal(-1)
    end

    it "must increment key and set count for new keys" do
      subject[:baz].must_be_nil
      subject[:baz] = 3
      subject[:baz].must_equal(3)
    end
  end

  describe "increment" do
    it "should increment existing keys" do
      subject[:bar].must_equal(2)
      subject.increment(:bar, -4)
      subject[:bar].must_equal(-2)
    end
    it "should increment new keys" do
      subject[:qux].must_be_nil
      subject.increment(:qux, 2)
      subject[:qux].must_equal(2)
    end
  end

  describe "<<" do
    it "should increment existing keys" do
      subject[:bar].must_equal(2)
      subject << :bar
      subject[:bar].must_equal(3)
    end
    it "should increment new keys" do
      subject[:qux].must_be_nil
      subject << :qux
      subject[:qux].must_equal(1)
    end
    it "should be chainable" do
      subject << :foo << :baz << :foo
      subject[:foo].must_equal(6)
      subject[:baz].must_equal(1)
    end
  end

  describe "#+" do
    let(:merged) { subject + other }
    it "should return a new set" do
      merged.must_be_instance_of(Funkiset)
      merged.wont_equal(subject)
      merged.wont_equal(other)
    end
    it "should sum the keys" do
      merged[:foo].must_equal(1)
      merged[:bar].must_equal(2)
      merged[:qux].must_equal(2)
    end
  end

  describe "#-" do
    let(:merged) { subject - other }
    it "should return a new set" do
      merged.must_be_instance_of(Funkiset)
      merged.wont_equal(subject)
      merged.wont_equal(other)
    end
    it "should sum the keys" do
      merged[:foo].must_equal(7)
      merged[:bar].must_equal(2)
      merged[:qux].must_equal(-2)
    end
  end

  describe "#&" do
    let(:merged) { subject & other }
    it "should reutrn a new set" do
      subject.must_be_instance_of(Funkiset)
      merged.wont_equal(subject)
      merged.wont_equal(other)
    end
    it "should return the intersection" do
      merged[:foo].must_equal(-3)
      merged[:bar].must_be_nil
      merged[:baz].must_be_nil
      merged[:qux].must_be_nil
    end
  end

  describe "#|" do
    let(:merged) { subject | other }
    it "should reutrn a new set" do
      subject.must_be_instance_of(Funkiset)
      merged.wont_equal(subject)
      merged.wont_equal(other)
    end
    it "should return the union" do
      merged[:foo].must_equal(4)
      merged[:bar].must_equal(2)
      merged[:baz].must_be_nil
      merged[:qux].must_equal(2)
    end
  end

  describe "#to_hash" do
    it "should return a hash" do
      subject.to_hash.must_equal(foo: 4, bar: 2)
    end
  end

  describe "#to_a" do
    it "should return an Array" do
      subject.to_a.must_equal([[:foo, 4], [:bar, 2]])
    end
  end

  describe "#sum" do
    it "should return the total of all counts" do
      subject.sum.must_equal(6)
    end
  end

  describe "#size" do
    it "should return the count of non-zero keys" do
      subject.size.must_equal(2)
    end
  end

  describe "#<=>" do
    let(:small) { Funkiset[:foo, :bar] }
    let(:large) { Funkiset[:foo, :bar, :baz, :foo, :bar, :qux, :foo, :bar] }
    let(:equal) { subject.dup }

    it "should return 1 when compared to a smaller set" do
      (subject <=> small).must_equal(1)
    end
    it "should return -1 when compared to a larger set" do
      (subject <=> large).must_equal(-1)
    end
    it "should return 0 when compared to an equal set" do
      (subject <=> equal).must_equal(0)
    end
  end
end