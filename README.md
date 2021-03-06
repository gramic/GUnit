<a href="http://www.boost.org/LICENSE_1_0.txt" target="_blank">![Boost Licence](http://img.shields.io/badge/license-boost-blue.svg)</a>
<a href="https://travis-ci.org/cpp-testing/GUnit" target="_blank">![Build Status](https://img.shields.io/travis/cpp-testing/GUnit/master.svg?label=linux/osx)</a>
<a href="http://github.com/cpp-testing/GUnit/issues" target="_blank">![Github Issues](https://img.shields.io/github/issues/cpp-testing/GUnit.svg)</a>
[![Join the chat at https://gitter.im/cpp-testing/GUnit](https://badges.gitter.im/cpp-testing/GUnit.svg)](https://gitter.im/cpp-testing/GUnit?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

---

## Testing

> "If you liked it then you should have put a test on it", Beyonce rule

## GUnit
> GoogleTest/GoogleMock/Cucumber on steroids

If you like/and or are struck with GoogleTest/GoogleMock/Cucmber-cpp on clang/gcc with C++14 you may want to consider using GUnit in order to improve your testing experience by:
* **No more hand written mocks**! (No more MOCK_CONST_METHODX)
* **No more base classes (SetUp/TearDown) and label as identifiers for GoogleTest** (GTEST/SHOULD)
* **No more need to instansiate and maintain mocks by hand** (GMake - Automatic mocks injection)
* **No more need for another tool (cucumber) and ruby to run BDD scenarios** (Gherkin - Given/When/Then)

## Motivation for GUnit

* [C++ Now 2017: Towards Painless Testing](https://www.youtube.com/watch?v=NVrZjT5lW5o)

### Example (TDD)

```cpp
GoogleTest/GoogleMock                           | GUnit
------------------------------------------------+---------------------------------------------
#include <gmock/gmock.h>                        | #include <GUnit.h> // one header
#include <gtest/gtest.h>                        |
                                                |
class mock_i1 : public i1 {                     | // mock_i1 is NOT NEEDED!
public:                                         |
 MOCK_CONST_METHOD1(f1, bool(int));             |
};                                              |
                                                |
class mock_i2 : public i2 {                     | // mock_i2 is NOT NEEDED!
public:                                         |
 MOCK_METHOD0(f2_1, void());                    |
 MOCK_METHOD0(f2_2, void());                    |
 MOCK_METHOD0(f2_3, void());                    |
 MOCK_METHOD0(f2_4, void());                    |
};                                              |
                                                |
class mock_i1 : public i1 {                     | // mock_i3 is NOT NEEDED!
public:                                         |
 MOCK_METHOD3(f3, void(int, int, int));         |
};                                              |
```

```cpp
struct ExampleTest : testing::Test {            |
 void SetUp() override {                        |
   sut = std::make_unique<example>(m1, m2, m3); | // SetUp IS OPTIONAL!
 }                                              |
                                                |
 mock_i1 m1;                                    | // members
 mock_i2 m2;                                    | // for
 mock_i3 m3;                                    | // testing
 std::unique_ptr<example> sut;                  | // are NOT NEEDED!
};                                              |
```

```cpp
TEST_F(ExampleTest, ShouldCallF1) {             |GTEST(example) { // set-up
 using namespace testing;                       | using namespace testing;
                                                |
 EXPECT_CALL(m1,f1(_)).WillOnce(Return(true));  | SHOULD("call f1") {
 EXPECT_CALL(m2,f2_1()).Times(1);               |  EXPECT_CALL(mock<i1>(),(f1)(_)).WillOnce(Return(true));
 EXPECT_CALL(m3,f3(0, 1, 2)).Times(1);          |  EXPECT_CALL(mock<i2>(),(f2_1)()).Times(1);
                                                |  EXPECT_CALL(mock<i3>(),(f3)(0, 1, 2)).Times(1);
 sut->test();                                   |
}                                               |  sut->test(); // sut and mocks were
                                                | }             // created automatically
TEST_F(ExampleTest, ShouldCallF2) {             |
 using namespace testing;                       | SHOULD("call f2") {
                                                |  EXPECT_CALL(mock<i1>(),(f1)(_)).WillOnce(Return(false));
 EXPECT_CALL(m1,f1(_)).WillOnce(Return(false)); |  EXPECT_CALL(mock<i2>(),(f2_2)()).Times(1);
 EXPECT_CALL(m2,f2_2()).Times(1);               |  EXPECT_CALL(mock<i3>(),(f3)(0, 1, 2)).Times(1);
 EXPECT_CALL(m3,f3(0, 1, 2)).Times(1);          |
                                                |  sut->test();
 sut->test();                                   | } // tear-down
}                                               |}
```

### Example (BDD)

* test/Features/Calc/addition.feature (Gherkin)
```gherkin
Feature: Calc Addition
  In order to avoid silly mistakes
  As a math idiot
  I want to be told the sum of two numbers

  Scenario: Add two numbers
    Given I have entered 20 into the calculator
      And I have entered 30 into the calculator
     When I press add
     Then the result should be 50 on the screen
```

#### Steps Implementation
```cpp
STEPS("Calc*") = [](auto steps) {
  Calculator calc{};
  double result{};

  steps.Given("I have entered {n} into the calculator") =
    [&](double n) {
      calc.push(n);
    };

  steps.When("I press add") =
    [&] {
      result = calc.add();
    };

  steps.When("I press divide") =
    [&] {
      result = calc.divide();
    };

  steps.Then("the result should be {expected} on the screen") =
    [&] (double expected) {
      EXPECT_EQ(expected, result);
    };

  return steps;
};
```

#### Usage
```sh
SCENARIO="test/Features/Calc/addition.feature" ./test --gtest_filter="Calc Addition.Add two numbers"
```

#### Output
```sh
[==========] Running 1 test from 1 test case.
[----------] Global test environment set-up.
[----------] 1 tests from Calc Addition
[ RUN      ] Calc Addition.Add two numbers
[    Given ] I have entered 20 into the calculator            # CalcSteps.cpp:12
[    Given ] I have entered 30 into the calculator            # CalcSteps.cpp:14
[     When ] I press add                                      # CalcSteps.cpp:16
[     Then ] the result should be 50 on the screen            # CalcSteps.cpp:19
[----------] Global test environment tear-down
[==========] 1 test from 1 test case ran. (7 ms total)
[  PASSED  ] 1 tests.
```

## GUnit
* Header only library (BDD/Gherkin support requires linking with libgherkin-cpp)
* Based on top of GoogleTest/GoogleMock
* Modular (GMock/GMake/GTest/GTest-Lite are independent)
  * `GUnit.GMock` - GoogleMock without hand written mocks
    * No more hand written mocks!
    * Support for more than 10 parameters
    * Quicker compilation times
    * Support for unique_ptr without any tricks
    * Support for overloaded operators
    * Support for mocking classes with constructors
    * 100% Compatible with Google Mocks
  * `GUnit.GMake` - Makes creation of System Under Test (SUT) and Mocks easier
    * No need to instantiate System Under Test and Mocks
      * Automatic mocks injection
  * `GUnit.GTest` - GooglTest with strings and more friendly macros
    * Test cases with string as names
    * No more SetUp/TearDown (SHOULD clauses)
    * One (GTEST) macro for all types of tests
    * 100% Compatible with tests using GTest
  * `GUnit.GTest-Lite` - lightweight, limited, no-macro way of defining simple tests
  * `GUnit.GScenario` - Gherkin/Cucumber implementation for C++ without Ruby dependencies
* Requirements
  * [C++14](https://ubershmekel.github.io/cppdrafts/c++14-cd.html)
  * [GoogleTest](https://github.com/google/googletest) (compatible with all versions)
  * Tested compilers
    * [Clang-3.6+](https://travis-ci.org/cpp-testing/GUnit)
    * [GCC-5+](https://travis-ci.org/cpp-testing/GUnit)
* Quick start
  ```sh
  $mkdir build && cd build && cmake ..
  $make && ctest
  ```

## Why GUnit it's based on GoogleTest/GoogleMock?

* [GoogleTest](https://github.com/google/googletest)
  * (+) Widely used (The most popular testing framework according to https://www.jetbrains.com/research/devecosystem-2017/cpp)
  * (+) Stable
  * (+) Powerful
  * (+) **Comes with GoogleMock**
  * (+) Well documented
  * (-) Macro based
  * (-) Slow to compile

* [GoogleMock](https://github.com/google/googletest)
  * (+) Widely used
  * (+) Stable
  * (+) Powerful
  * (+) Well documented
  * (-) Hand written mocks
    * Who likes writing and maintaining these?
    ```cpp
    class MockInterface : public interface {
    public:
      MOCK_CONST_METHOD1(get, bool());
      MOCK_METHOD1(set, void(bool));
    };
    ```
  * (-) Macro based
  > Towards Painless Testing with GoogleTest and GoogleMock.
15
* (-) Slow to compile

## GUnit.GMock
 * **GoogleMock without writing and maintaining mocks by hand**
 * Supported features
   * `EXPECT_CALL` (requires additional parens for function call)
   ```cpp
   EXPECT_CALL(mock, function(42)).WillOnce(Return(true)); // GoogleMock
   EXPECT_CALL(mock, (function)(42)).WillOnce(Return(true)); // GUnit.GMock
   EXPECT_INVOKE(mock, function, 42) // GUnit.GMock
   ```
   * `ON_CALL` (requires additional parens for function call)
   ```cpp
   ON_CALL(mock, function()).WillByDefault(Return(true)); // GoogleMock
   ON_CALL(mock, (function)()).WillByDefault(Return(true)); // GUnit.GMock
   ```
   * `Return/ReturnRef`
   * `WaggyMock/StrictMock/NiceMock`
   * Compile error when parameters and expectations don't match
   * It works together with traditional GoogleMock mocks (See [Example](https://github.com/cpp-testing/GUnit/blob/master/test/GMock.cpp))
* Synopsis
  ```cpp
  namespace testing {
    template <class T>
    class GMock {
      static_assert(std::is_abstract<T>::value, "T has to be an abstract type");
      static_assert(std::has_virtual_destructor<T>::value, "T has to have a virtual destructor");

      GMock() = default;
      GMock(GMock &&) = default;
      GMock(const GMock &) = delete;

    public:
      using type = T;

      T&() object();
      const T&() object() const;

      explicit operator T&();
      explicit operator const T&() const;
    };

    template <class T>
    using NaggyGMock = GMock<T>;

    template <class T>
    using StrictGMock = StrictMock<GMock<T>>;

    template <class T>
    using NiceGMock = NiceMock<GMock<T>>;

    /**
     * [Proposal - generic factories]
     *   http://www.open-std.org/jtc1/sc22/wg21/docs/papers/2016/p0338r0.pdf
     *
     * @tparam T type to be created ex. std::unique_ptr<example>
     * @param args arguments (converts GMock for given types T*, T&, shared_ptr, unique_ptr)
     * @return T instance
     */
    template <class T, class... TArgs>
    auto make(TArgs&&... args);
  } // testing

  template<class TMock>
  auto object(TMock&); // converts mock to the underlying type
  ```

## GUnit.GMock - Tutorial by example

```cpp
class iconfig {
 public:
  virtual bool is_dumpable() const = 0;
  virtual ~iconfig() = default;
};
```

```cpp
class iprinter {
 public:
  virtual ~iprinter() = default;
  virtual void print(const std::string& text) = 0;
};
```

```cpp
class example {
 public:
  example(const iconfig& config, const std::shraed_ptr<iprinter>& printer)
    : config(config), printer(printer)
  { }

  void update() {
    if (config.is_dumpable()) {
      printer->print("text");
    }
  }

 private:
  const iconfig& config;
  std::shared_ptr<iprinter> printer;
};
```

### Test (V1)
```cpp
TEST(Test, ShouldPrintTextWhenUpdate) {
  using namespace testing;
  GMock<iconfig> mockconfig; // defines and creates a mock
  auto mockprinter = std::make_shared<GMock<iprinter>>(); // defines and creates a mock

  example sut{static_cast<const iconfig&>(mockconfig)
            , object(mockprinter)};

  EXPECT_CALL(mockconfig, (is_dumpable)()).WillOnce(Return(true)); // additional parens
  EXPECT_CALL(*mockprinter, (print)("text")); // additional parens

  sut.update();
}
```

* (+) **NO HAND WRITTEN MOCKS**
* (-) Additional casting of mocks is required
* (~) Additional parens with a method call

> Can we do better?

### Test (V2) / using make

```cpp
TEST(Test, ShouldPrintTextWhenUpdate) {
  using namespace testing;
  StrictGMock<iconfig> mockconfig; // strict mock
  auto mockprinter = std::make_shared<StrictGMock<iprinter>>(); // strict mock

  auto sut = make<example>(mockconfig, mockprinter); // automatically converts mocks to interfaces

  EXPECT_CALL(mockconfig, (is_dumpable)()).WillOnce(Return(true));
  EXPECT_CALL(*mockprinter, (print)("text"));

  sut.update();
}
```

* (+) No castings required

> Is the make call generic?

### Test (V2.1) / using make and unique_ptr

```cpp
TEST(Test, ShouldPrintTextWhenUpdate) {
  using namespace testing;
  StrictGMock<iconfig> mockconfig;
  auto mockprinter = std::make_shared<StrictGMock<iprinter>>();

  // create a unique_ptr
  auto sut = make<std::unique_ptr<example>>(mockconfig, mockprinter);

  EXPECT_CALL(mockconfig, (is_dumpable)()).WillOnce(Return(true));
  EXPECT_CALL(*mockprinter, (print)("text"));

  sut->update();
}
```

### GMock conversion to the underlying type

```cpp
foo_ref(IFoo&);
foo_ptr(IFoo*);

int main() {
  GMock<IFoo> mock;
  foo_ref(object(mock)); // converts mock to IFoo&
  foo_ptr(object(mock)); // converts mock to IFoo*
};
```

```cpp
foo_up(std::unique_ptr<IFoo>);
foo_ref(IFoo&);
foo_ptr(IFoo*);

int main() {
  std::unique_ptr<StrictGMock<IFoo>> mock
    = std::make_unique<StrictGMock<IFoo>>();

  foo_up(object(mock));  // converts mock to std::unique_ptr<IFoo>
  foo_ref(object(mock)); // converts mock to IFoo&
  foo_ptr(object(mock)); // converts mock to IFoo*
}
```

```cpp
foo_up(std::shared_ptr<IFoo>);
foo_ref(IFoo&);
foo_ptr(IFoo*);

int main() {
  std::shared_ptr<StrictGMock<IFoo>> mock
    = std::make_shared<StrictGMock<IFoo>>();

  foo_sp(object(mock));  // converts mock to std::shared_ptr<IFoo>
  foo_ref(object(mock)); // converts mock to IFoo&
  foo_ptr(object(mock)); // converts mock to IFoo*
}
```

### How to mock overloaded methods?

```cpp
class interface {
 public:
  virtual void f(int) = 0;
  virtual void f(int) const = 0;
  virtual ~interface() = default;
};

GMock<interface> mock;

EXPECT_CALL(mock, (f, void(int) const)(1));
EXPECT_CALL(mock, (f, void(int))(2));

static_cast<const interface&>(mock).f(1);
mock.object().f(2);
```

### Universal EXPECT_* syntax (works with Google Mock's and GUnit.GMock's)

```cpp
struct IFoo {
  virtual ~IFoo() noexcept = default;
  virtual bool foo(int) = 0;
};
```
```cpp
GMock<IFoo> mock;
EXPECT_INVOKE(mock, foo, 42).WillOnce(Return(42));
// same as EXPECT_CALL(mock, (foo)(42)).WillOnce(Return(42));
```

### Mocking templates?

* Simple, just put an interface on it!

#### Example
```cpp
struct Generic {
  template<class... Ts>
  void foo(Ts...) const;
};

template<class T>
class GenericExample {
public:
  explicit GenericExample(const T&);
  void bar() {
    t.foo(42, 77.0); // call via templated object
  }

private:
  const T& t;
};

/**
 * Needed for testing but it's still better than MOCK_CONST_METHOD2
 */
struct IGeneric {
  virtual ~IGeneric() = 0;
  virtual void foo(int, double) const = 0;
};

StrictGMock<IGeneric> generic{};
GenericExample<IGeneric> sut{object(generic)};

EXPECT_CALL(generic, (foo)(42, 77.0));

sut.bar();
```

### [Advanced] Constructors with non-interface parameters and make (Assisted Injection)

```cpp
  example(iconfig& config, int value, const std::shared_ptr<iprinter>& printer, int data);
                            ^                                                   ^
                            \_____________________       _______________________/
                                                  \     /
  std::tie(sut, mocks) = make<example, StrictMock>(42, 77); // order of the same types is important
                                                            // but it's not imortant for unique types
```

### [Advanced] Generic Factories

```cpp
template <class T, class... TArgs>
struct IFactory {
  virtual T create(TArgs...) = 0;
  virtual ~IFactory() = default;
};
```

```cpp
using IConfigFactory = IFactory<IConfig, std::string>;
```

```cpp
GMock<IConfig> mockconfig;
EXPECT_CALL(mock<IConfigFactory>(), (create)("string")).WillOnce(Return(mockconfig));
```

* **(+) No specfic factory mocks for given number of parmaeters**
* (+) Factory aliases can be used to determine the mock

---

## GUnit.GMake

* **Removes boilerplate mocks declaration**
* **Creates System Under Test (SUT) the same way despite the constructor changes**
* Synopsis
  ```cpp
  namespace testing {
    /**
     * [Proposal - generic factories]
     *   http://www.open-std.org/jtc1/sc22/wg21/docs/papers/2016/p0338r0.pdf
     *
     * @tparam T type to be created ex. std::unique_ptr<example>
     * @tparam TMock mock type
     *          NaggyMock  - warning (default)
     *          StrictMock - error
     *          NiceMock   - ignore
     *
     * @tparam TMocks specific mocks different than defaulted by TMock
     *          ex. StrictGMock<interface>
     *
     * @param args arguments (converts GMock for given types T*, T&, shared_ptr, unique_ptr)
     * @return pair{T, mocks}
     */
    template <class T, template <class> class TMock, class... TMocks, class... TArgs>
    auto make(TArgs&&... args);

    template <class T>
    class GTest : public Test {
    public:
      using SUT = std::unique_ptr<T>;

    protected:
      template <class TMock>
      decltype(auto) mock();

      SUT sut;
      mocks_t mocks;
    };
  } // testing
  ```

## GUnit.GMake - Tutorial by example

### Test (V3 - C++17)

```cpp
TEST(Test, ShouldPrintTextWhenUpdate) {
  using namespace testing;
  auto [sut, mocks] = make<example, NaggyMock>(); // create NaggyMocks when required

  EXPECT_CALL(mocks.mock<iconfig>(), (is_dumpable)()).WillOnce(Return(true));
  EXPECT_CALL(mocks.mock<iprinter>(), (print)("text"));

  sut.update();
}
```
* (+) Required mocks are created automatically
* (+) `example` constructor might be refactored without changing test cases!

  ```cpp
  make<example, NaggyMock>() can create...
    example(const std::shared_ptr<iprinter>& printer, const iconfig& config);
    example(const iconfig& config, iprinter& printer);
    example(iconfig* config, iprinter* printer);
    ...
  ```

### Test (V3 - C++14)

```cpp
TEST(Test, ShouldPrintTextWhenUpdate) {
  using namespace testing;
  std::unique_ptr<example> sut;
  mocks_t mocks;
  std::tie(sut, mocks) = make<std::unique_ptr<example>, StrictMock>(); // create StrictMock when required

  EXPECT_CALL(mocks.mock<iconfig>(), (is_dumpable)()).WillOnce(Return(true));
  EXPECT_CALL(mocks.mock<iprinter>(), (print)("text"));

  sut->update();
}
```

> Let's refactor (remove duplicates) from V3 then!

### Test (V4) / using GUnit.GMake

```cpp
class Test : public testing::Test {
public:
  void SetUp() override {
    std::tie(sut, mocks) =
      testing::make<std::unique_ptr<example>, NaggyMock>();
  }
};
```

```cpp
TEST(Test, ShouldPrintTextWhenUpdate) {
  using namespace testing;
  EXPECT_CALL(mock<iconfig>(), (is_dumpable)()).WillOnce(Return(true));
  EXPECT_CALL(mock<iprinter>(), (print)("text"));

  sut->update();
}
```

* (+) **No repetitions with more than 1 test!**

---

## GUnit.GTest
* **Simplifies usage of GoogleTest (no more label as test case names!)**

* Synopsis
  ```cpp
    #define GTEST(type_to_be_tested OR test_case_name,
                  [optional] additional_test_case_name,
                  [optional] parametric test values);
    #define DISABLED_GTEST(...); // disable test

    #define SHOULD(test_case_name); creates a new test case inside GTEST
    #define DISABLED_SHOULD(test_case_name); // disable should clause (test case)
  ```

## GUnit.GTest - Tutorial by example

> Simple test
```cpp
GoogleTest                                      | GUnit
------------------------------------------------+---------------------------------------------
TEST(SimpleTest, ShouldDoNothing)               | GTEST("Should do nothing")
{ }                                             | { }
```

> Simple test with a fixture
```cpp
GoogleTest                                      | GUnit
------------------------------------------------+---------------------------------------------
TEST(SimpleTest, ShouldDoNothing)               | GTEST("Simple Test", "Should do nothing")
{ }                                             | { }
```

> Test with a base class
```cpp
GoogleTest                                      | GUnit
------------------------------------------------+---------------------------------------------
struct FooTest : testing::Test { };             | struct FooTest : testing::Test { };
                                                |
TEST_F(FooTest, ShouldDoNothing)                | GTEST(FooTest, "Should do nothing")
{ }                                             | { }
```

> Multiple tests with a base class
```cpp
GoogleTest                                      | GUnit
------------------------------------------------+---------------------------------------------
struct FooTest : testing::Test { };             | struct FooTest : testing::Test { };
                                                |
TEST_F(FooTest, ShouldDoNothingTest1) { }       | GTEST(FooTest, "Should do nothing test 1") { }
TEST_F(FooTest, ShouldDoNothingTest2) { }       | GTEST(FooTest, "Should do nothing test 2") { }
```

> Test with SUT/Mocks creation
```cpp
GoogleTest                                      | GUnit
------------------------------------------------+---------------------------------------------
class IFoo;                                     | class IFoo;
class Example;                                  | class Example;
                                                |
TEST(FooTest, ShouldCallFoo) {                  | GTEST(Example, "Should call foo") {
  std::shared_ptr<StrictGMock<IFoo>> fooMock    |   EXPECT_CALL(mock<IFoo>(), (foo)())
   = std::make_shared<StrictGMock<IFoo>>();     |     .WillOnce(Return(42));
                                                |   EXPECT_EQ(42, sut->run());
  std::unique_ptr<Example> sut                  | }
   = std::make_unique<Example>(object(fooMock));|
                                                |
  EXPECT_CALL(*fooMock, (foo)())                |
    .WillOnce(Return(42));                      |
  EXPECT_EQ(42, sut->run());                    |
}                                               |
```

> Multiple tests with SUT and Mocks
```cpp
GoogleTest                                      | GUnit
------------------------------------------------+---------------------------------------------
class IFoo;                                     | class IFoo;
class Example;                                  | class Example;
                                                |
struct FooTest : testing::Test {                | GTEST(Example) {
  std::shared_ptr<StrictGMock<IFoo>> fooMock    |   std::cout << "set up" << '\n';
   = std::make_shared<StrictGMock<IFoo>>();     |
  std::unique_ptr<Example> sut                  |   SHOULD("call foo") {
   = std::make_unique<Example>(object(fooMock));|     EXPECT_CALL(mock<IFoo>(), (foo)())
                                                |       .WillOnce(Return(42));
  void SetUp() override {                       |     EXPECT_EQ(42, sut->run());
    std::cout << "set up" << '\n';              |   }
  }                                             |
                                                |   SHOULD("call foo and return 0") {
  void TearDown() override {                    |     EXPECT_CALL(mock<IFoo>(), (foo)())
    std::cout << "tear down" << '\n';           |       .WillOnce(Return(0));
  }                                             |     EXPECT_EQ(0, sut->run());
};                                              |   }
                                                |
TEST_F(FooTest, ShouldCallFoo) {                |   std::cout << "tear down" << '\n';
  EXPECT_CALL(*fooMock, (foo)())                | }
    .WillOnce(Return(42));                      |
  EXPECT_EQ(42, sut->run());                    | // There are 2 tests cases here!
}                                               | //   1.	Example.Should call foo
                                                | //   2. Example.Should call foo and return 0
TEST_F(FooTest, ShouldCallFooAndRet0) {         | //
  EXPECT_CALL(*fooMock, (foo)())                | // SetUp and TeardDown will be called
    .WillOnce(Return(0));                       | // separately for both of them
  EXPECT_EQ(0, sut->run());                     |
}
```

> Disable simple test
```cpp
GoogleTest                                      | GUnit
------------------------------------------------+---------------------------------------------
TEST(DISABLED_Test, ShouldDoSomething)          | DISABLED_GTEST("Should do something")
{ }                                             | { }
```

> Disable multiple tests
```cpp
GoogleTest                                      | GUnit
------------------------------------------------+---------------------------------------------
TEST_F(FooTest, DISABLED_ShouldDoA) {}          | DISABLED_GTEST(FooTest) {
TEST_F(FooTest, DISABLED_ShouldDoB) {}          |   SHOULD("Do A") {}
                                                |   SHOULD("Do B") {}
                                                | }
```

> Disable some tests
```cpp
GoogleTest                                      | GUnit
------------------------------------------------+---------------------------------------------
TEST_F(FooTest, ShouldDoA) {}                   | GTEST(FooTest) {
TEST_F(FooTest, DISABLED_ShouldDoB) {}          |   DISABLED_SHOULD("Do A") {}
```                                             |   SHOULD("Do B") {}
                                                | }
```

> Parametrized tests
```cpp
GoogleTest                                      | GUnit
------------------------------------------------+---------------------------------------------
class ParamTest :                               | GTEST("ParamTest", "[InstantiationName]",
  public ::testing::TestWithParam<int> { };     |       testing::Values(1, 2, 3)) {
                                                |  SHOULD("be true") { EXPECT_TRUE(GetParam() >= 1; }
TEST_P(ParamTest, ShouldbeTrue) {               |  SHOULD("be false") { EXPECT_FALSE(false); }
  EXPECT_TRUE(GetParam() >= 1);                 | }
}                                               |
                                                |
TEST_P(ParamTest, ShouldBeFalse) {              |
  EXPECT_FALSE(false);                          |
}                                               |
                                                |
INSTANTIATE_TEST_CASE_P(                        |
  InstantiationName,                            |
  ParamTest,                                    |
  testing::Values(1, 2, 3)                      |
);                                              |
 ```

> Note Running specific `should` test case requires ':' in the test filter (`--gtest_filter="test case pattern:should pattern"`)

*  --gtest_filter="FooTest*:Do A"  # calls FooTest with should("Do A")
*  --gtest_filter="FooTest*:-Do A" # calls FooTest with not should("Do A")
*  --gtest_filter="FooTest*:Do*"   # calls FooTest with should("Do...")
*  --gtest_filter="FooTest.:Do*"   # calls FooTest with should("Do...")
*  --gtest_filter="-FooTest?:-Do*" # calls not FooTest with not should("Do...")

#### Example output

```sh
[----------] 1 tests from Example
[ RUN      ] Example.Return
[ SHOULD   ] return true
[ SHOULD   ] return false
[       OK ] Example.Return (0 ms)
[----------] 1 tests from Example (0 ms total)
```

## GUnit.GTest-Lite
* Synopsis
  ```cpp
  template <class T, T...>
  constexpr auto operator""_test;

  template <class T, T...>
  constexpr auto operator""_test_disabled;
  ```

## GUnit.GTest-Lite - Tutorial by example
```cpp
int main() {
  "should always be true"_test = [] {
    EXPECT_TRUE(true);
  };

  "should not be run"_test_disabled = [] {
    EXPECT_TRUE(false);
  };
}
```

---

## Integration tests with Dependency Injection ([[Boost].DI](https://github.com/boost-experimental/di))

```cpp
class example; // System Under Test

GTEST(example) {
  namespace di = boost::di;

  SHOULD("create example") {
    const auto injector = di::make_injector(
      di::bind<interface>.to(di::NiceGMock{mocks})
    , di::bind<interface2>.to(di::StrictGMock{mocks})
    );

    sut = testing::make<SUT>(injector);

    EXPECT_CALL(mock<interface>(), (get)(_)).WillOnce(Return(123));
    EXPECT_CALL(mock<interface2>(), (f2)(123));

    sut->update();
  }
}
```

---

## GUnit.GScenario - BDD (Given/When/Then - Gherkin) scenarios

* Synopsis
  ```cpp
  /**
   * @param feature regex expression matching a feature name
   *        example: "Calc*"
   */
  #define STEPS(feature) // register steps for a feature

  namespace testing {
    /**
     * Thrown when implementation for given step can't be found
     */
    struct StepIsNotImplemented : std::runtime_error;

    /**
     * Thrown when more than one implementation for given step was be found
     */
    struct StepIsAmbiguous : std::runtime_error;

    /**
     * Verify whether parameters provided in the step and lambda expression
     * matches at compile-time
     */
    constexpr auto operator""_step();

    /**
     * Table parameters from the scenario
     */
    using Table = vector<unordered_map<string_key, string_value>>;

    /**
     * Map Gherkin steps (feature file) to implementation
     */
    class Steps {
      /**
       * @param pattern step description (support simple regex)
       *        might be followed by _step to verify parameters at compile time
       * @param table optional table parameter, lambda expression will need a Table parameter
       *
       * Lambda expression has to be assigned
       */
      auto Given(auto pattern, auto table = none);

      /**
       * Same as Given but it will show file/line from cpp files instead of feature file
       */
      auto $Given(auto pattern, auto table = none);

      auto When(auto pattern, auto table = none);
      auto $When(auto pattern, auto table = none);

      auto Then(auto pattern, auto table = none);
      auto $Then(auto pattern, auto table = none);
    };
  } // testing
  ```

* Usage

```cpp
/**
 * @param args default-constructible types to be injected
 */
STEPS("*") = [](auto steps, args...) {
  // initialize test objects here
  return steps; // has to return steps
};
```

* test/Features/Calc/addition.feature
```gherkin
Feature: Addition
  In order to avoid silly mistakes
  As a math idiot
  I want to be told the sum of two numbers

  Scenario Outline: Add two numbers
    Given I have entered <input_1> into the calculator
    And I have entered <input_2> into the calculator
    When I press <button>
    Then the result should be <output> on the screen

  Examples:
    | input_1 | input_2 | button | output |
    | 20      | 30      | add    | 50     |
    | 2       | 5       | add    | 7      |
    | 0       | 40      | add    | 40     |
    | 3       | 222     | add    | 225    |
```

#### Steps Implementation
```cpp
const auto CalcPush = [](auto& calc) {
  return [&](double n) {
    calc.push(n);
  };
};

const auto CalcAdd = [](auto& calc, auto& result) {
  return [&] {
    result = calc.add();
  };
};

const auto CalcDivide = [](auto& calc, auto& result) {
  return [&] {
    result = calc.divide();
  };
};

const auto CalcResult = [](auto& result) {
  return [&](double expected) {
    EXPECT_EQ(expected, result);
  };
};

STEPS("Calc*") = [](auto steps, Calculator calc, double result) {
  steps.Given("I have entered {n} into the calculator"_step)   = CalcPush(calc);
  steps.When ("I press add")                                   = CalcAdd(calc, result);
  steps.When ("I press divide")                                = CalcDivide(calc, result);
  steps.Then ("the result should be {expected} on the screen") = CalcResult(result);
  return steps;
};
```

#### Usage
```sh
SCENARIO="test/Features/Calc/addition.feature" ./test --gtest_filter="Calc Addition.Add two numbers"
```

### GWT and Mocking?

```cpp
STEPS("Calc*") = [](auto steps) {
  testing::GMock<IDisplay> display{DEFER_CALLS(IDisplay, show)};
  CalculatorUI calc{testing::object(display)};

  steps.Given("I have entered {n} into the calculator") =
    [&](double n) {
      calc.push(n);
    };

  steps.When("I press add") =
    [&]{ calc.add(); };

  steps.Given("I press divide") =
    [&]{ calc.divide(); };

  steps.Then("the result should be {expected} on the screen") =
    [&] (double expected) {
      EXPECTED_CALL(display, (show)(expected));
    };

  return steps;
};
```

> Note Running specific `scenario` requires ':' in the test filter (`--gtest_filter="feature.scenario"`)

*  --gtest_filter="Calc Addition.Add two numbers"  # calls Calc features test using Addition feature and Add two numbers scenario

---

### Limitations

* GMock can't mock classes with multiple or virtual inheritance
* GMock, by default, can fake interface with up to 128 virtual methods

### FAQ

* How `GMock` works?
  * It's not a C++ standard solution (depends on vtable implementation)
    * [Itanium C++ ABI (vtable)](https://mentorembedded.github.io/cxx-abi/abi.html)
    * [VTable in GCC](http://stackoverflow.com/questions/6258559/what-is-the-vtt-for-a-class)
    * [Deleting Destructors](http://eli.thegreenplace.net/2015/c-deleting-destructors-and-virtual-operator-delete)
    * [Devirtualization in C++](http://hubicka.blogspot.com/2014/01/devirtualization-in-c-part-1.html)
    * [Member Function Pointers and the Fastest Possible C++ Delegates](https://www.codeproject.com/kb/cpp/fastdelegate.aspx)
    * [Reversing C++ Virtual Functions](https://alschwalm.com/blog/static/2016/12/17/reversing-c-virtual-functions)
    * [C++ vtables](http://shaharmike.com/cpp/vtable-part1)
    * ```g++ -fdump-class-hierarchy interface.hpp```

  * Similar projects ([FakeIt](https://github.com/eranpeer/FakeIt), [HippoMocks](https://github.com/dascandy/hippomocks))

* How quick is `GMock`?
  * Compile time [benchmark (Example)](https://github.com/cpp-testing/GUnit/tree/master/benchmark)

      | Compiler | Number of Mocks | GoogleMock/GoogleTest | GoogleMock/GoogleTest + GUnit |
      | -------- | --------------- | --------------------- | ----------------------------- |
      | GCC-6    |               3 |                  2.6s |                         2.1s  |
      | Clang-3.9|               3 |                  2.3s |                         1.9s  |

* But virtual function call has performance overhead?
  * This statement is not really true anymore with modern compilers as most virtual calls might be inlined
    * [Devirtualization in C++](http://hubicka.blogspot.co.uk/2014/01/devirtualization-in-c-part-2-low-level.html)
    * [Using final - C++11](https://godbolt.org/g/ASLk4B)
    * [Link Time Optimization - LTO](http://hubicka.blogspot.co.uk/2014/04/linktime-optimization-in-gcc-1-brief.html)

### Acknowledgements
* Thanks to Eran Pe'er and Peter Bindels for [FakeIt](https://github.com/eranpeer/FakeIt) and [HippoMocks](https://github.com/dascandy/hippomocks)

### References
* [C++ Now 2017: Mocking C++](https://www.youtube.com/watch?v=t0wLm2iiEH0)
* [Meeting C++ 2016: TDD/BDD and Dependency Injection](https://www.youtube.com/watch?v=T3uMcxhzRUE)
* [Automatic Mocks Injector](https://github.com/cpp-testing/mocks_injector)
* [[Boost].DI](https://github.com/boost-experimental/di) - Dependency Injection Library
* [VC](https://github.com/boost-experimental/vc) - Virtual Concepts Library
