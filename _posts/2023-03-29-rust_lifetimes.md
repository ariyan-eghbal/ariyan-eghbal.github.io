---
layout: post
title:  Rust lifetimes
#date: {{ "now" | date: "%Y-%m-%d %H:%M" }} +0330
categories: [Programming, Rust]
tags: [rust,lifetime]
author: ryn
---

# Ownership, Borrowing and Lifetimes
The main reputation of Rust is its compile-time memory safety. There are three main methods of memory management:
- Manual Memory Management (like C and C++)
  Which depends on programmmer's skill, experience and diligence. Programmer is responsible for allocation and deallocation of memory and prevention of memory leaks and dangling pointers. obviously this method has a lot of pitfalls and can get very complicated

- Runtime Memory Management (e.g. Garbage collector like Java or thechniques like Smart Pointers like Python)
  Runtime environment manages memory and programmer has very little control over memory. It is simple for writing programs but performance will be very poor. program needs a runtime environment like JRE which must be installed separately or being embeded with final executable so final executable will be either large or runtime framework dependant

- Compile-Time Memory Management (e.g. Rust)
  Rules for using variables and allocation/deallocation and referencing of memory are applied on compile-time. Compiler ensures variables cannot point to invalid memory and decides when and how to allocate and deallocate memory. so there will be no runtime memory management footprint and program can have good performance like manual memory management while it is not required for programmer to strugle with complicated design patterns or be very skilled to prevent leaks and dangings


## Ownership

In Rust every memory location is **owned** by a **single** variable and every variable has a mutablity binding which indicates if we can change it or not and a lifetime binding which indicates how long its memory value is valid for sure. this way it is not possible multiple variables form a race condition on memory so it is not possible to have dangling pointers and memory leaks.

When we assign a value to a variable Rust by default transfers its ownership so the old variable loses ownership and new variable gets the ownership (either simple `=` assignment or assignment via function call).


```rust
// (Here we used `struct` for a reason)
struct Data{
  value: i32;
}

fn test(data: Data){
  ...
}

fn main(){
  let a = Data{value: 10};  // Now a owns memory

  let b = a;                // Here memory's ownership is transfered to b and
                            // a is not valid anymore and we cannot use it anymore

  test(b)                   // And now memory is transfered from b to data variable
                            // in test function so b is not valid anymore

}
```

In this example we used `struct` because when we do assignment two things can happen:
1. Ownership transfer: default behavior for everything except 2nd case
2. Copy: if data type implement `Copy` trait (traits are same as `Interface` in OOP)

Simple data types like integers implement `Copy` trait (because it is expected from them to be copied from the programmer sight of view). so if we have used a simple data type like `i32` or `u64` we couldn't see the ownership transfer behavior.

As a rule owner of memory is responsible for deallocation of that memory so memory is freed as soon as its owner is destroyed

This rule has a problem when we encounter with large or complex datatypes or function calls. when we call a function we lose ownership of memory so we cannot use it anymore so we need a technique to return ownership to caller (like returning value which will result in problems with multiple parameters). also if we have a complex datatype (like a `struct` or array) and try to use their internal items we need to take ownership of items which results in partial move of ownership and takes control of parts of datatype which results to inconsistency or we need to copy that value which can result performance problems with large data and requires implementation of `Copy` trait which can result into losing ownership capability entirely because now assignment copies datatype.

As you can see ownership by itself is not enough and can be very limiting.

## Borrowing
As a solution to above problems we can borrow memory. this concept is same as borrowing in C++ but it is constrained with some rules.
we borrow memory using `&` (like refereces in C++):

```rust
struct Data{
  value: i32;
}

fn test(data: &Data){
  ...
}

fn main(){
  let a = Data{value: 10};  // Now a owns memory

  let b = &a;               // Here we borrow memory of a and type of b is &Data
                            // and the owner of memory is still a

  test(&a);                 // Here test borrows a so ownership of memory is not changed
}
```

With borrowing compiler can decide how to access the memory without changing ownership or copying data (it can be done via pointers or some other way)

There are rules about borrowing in Rust which we will get into soon.
All variables in Rust are immutable by default which means we cannot change their value. to make a variable mutable we annotate them with `mut` keyword. and you can both mutate variable and value separately. Rust actually has a mutablity state (binding) for variable and another one for value, so :

- `let a: T`
- `let mut a: T`

a `mut` binding (making a variable `mut`) means we can reassign a variable to a new value (change the variable's value)
and with borrowing:
- `let a: &T`
- `let a: &mut T`
- `let mut a: &T`
- `let mut a: &mut T`

ٌWhen we use `&mut` it means we have a changable referece so we can change target value.

```rust
fn main(){
  let a = Data{value: 10};
  a.value = 20;             // This fails

  let mut b = Data{value: 10};
  b.value = 20;             // This works
}
```

mutablity and immutablity is a variable binding in Rust which means it can be changed. so:

```rust
fn main(){
  let a = Data{value: 10};

  let mut b = a;
  b.value = 20;             // This works, a was immutable but we moved
                            // ownership to b which is mutable so we can
                            // change the value via b and a is now invalid
}
```

we also can borrow as mutable (via `&mut`) or immutable (via `&`) if original owner be mutable (if original owner be immutable we can only borrow as immutable):

```rust
fn main(){
  let mut a1 = Data{value: 10};
  let mut a2 = Data{value: 20};

  let b = &a1;
  b.value = 30;             // This fails as b is an immutable borrow of a
  b = &a2                   // We cannot change neither target value nor b itself

  let mut c = &a1;
  c.value = 30;             // This fails as b is an immutable borrow of a
  c = &a2;                  // but we can change c to point somewhere else

  let d = &mut a1;
  d.value = 30;             // This works as d is an mutable borrow of a
  d = &a2;                  // We cannot change d as variable is bound as immutable

  let e = &mut a1;
  e.value = 30;             // This works as d is an mutable borrow of a
  e = &mut a2;              // and we can also change e to point somewhere else

}
```

as a comparison with C++ we can summerize:

| Rust              | C++              |                                          |
|-------------------|------------------|------------------------------------------|
| let a: &T         | const T* const a | Cannot change neither a nor target       |
| let mut a: &T     | const T* a       | Can change a but cannot change target    |
| let a: &mut T     | T* const a       | Cannot change a but we can change target |
| let mut a: &mut T | T* a             | We can change both                       |

## Lifetimes

As other languages Rust has automatic lifetimes. Lifetimes are related to stack, rust allocates into stack by default and every variable in _stack_ lives until the end of the block which its _owner_ is defined.
So when you have a variable you have a automatic lifetime which lasts until the end of its owner's block. This is simple, you define something and it lasts until the end of blocks, even if you shadow a variable (`let` same name again) still memory is freed at the end of block:

```rust

#[derive(Debug)]
struct Data{
  _value: i32
}

impl Drop for Data {
    fn drop(&mut self) {
        println!("Dropped")
    }
}


fn main(){
    let v = Data{_value: 10};
    println!("Created v: {:?}", v);
    let v = 20;
    println!("v is now overwritten");
    println!("{:?}", v);
    println!("Exit")
}
```
so we keep blocks small and we have effecient programs. The problem appears when we need some data live longer than its block.
When we need a function return a value we can return value and ownership rules applies:

```rust
fn main() {
    let x = 5;
    let y = 10;

    let z = add(x, y);

    println!("{:?}", z);
}

fn add(a: i32, b: i32) -> i32{
    a + b
}
```
Here `i32` has `Copy` trait and result is copied into `z`
Or with a data type without `Copy` trait ownership is transfered:
```rust
#[derive(Debug)]
struct Data{
  _value: i32
}


fn main() {
    let x = 5;
    let y = 10;

    let z = add(x, y);

    println!("{:?}", z);
}

fn add(a: i32, b: i32) -> Data {
    Data{_value: a + b}
}
```
But if you try to allocate memory in function and return a referece to it you face lifetime problem; rust cannot apply automatic lifetimes to resulting memory because it doesnt know return value of function's lifetime, memory is owned by function and you are returning a referece so memory must be deallocated after function call but returning a referece to that memory will cause dangling pointer (it points to an invalid address):
```rust
#[derive(Debug)]
struct Data{
  _value: i32
}

fn main() {
    let x = 5;
    let y = 10;

    let z = add(x, y);

    println!("{:?}", z);
}

fn add(a: i32, b: i32) -> &Data {
    &Data{_value: a + b}
}
```
Here rust will not compile the code as a result of memory safety rules. you must tell rust when it can free memory of return value of function.
When you borrow something the owner may free memory even before you finish your work with borrowed data:
```rust
fn main(){
    let r: &i32;
    {
        let x = 10;
        r = &x;
    }
    println!("{:?}", r);
}
```
Here `r` is refering to `x` which is owned by inner block which its stack frame is freed when we try to use the reference. so we have a dangling pointer.
In rust you must tell compiler about how long a memory must be valid when you work with references. so compiler can decide on how and where store a value.
We tell about lifetimes by anotating references with labels in format of `'a`, `'b`, ... and tie them to owned variables so we can be sure a reference is valid while another owned variable is valid.
In rust we have to type of labels:
- `'label` like `'a`, `'b`, `'test`, ... which we use to tie a referece's lifetime to an owned variable, the format for this `...: 'a` which means `...` outlives more than `'a`, and it means `...` is valid at least as much as `'a` lives.
- `'static` which roughly means infinite time

for example if we write a function which gets two refereces and returns a referece we annotate it like this (define labels in function and annotate variables):
```rust
fn main() {
    let x = 5;
    let y = 10;

    let z = max(&x, &y);

    println!("{:?}", z);
}

fn max<'a>(a: &'a i32, b: &'a i32) -> &'a i32 {
    if a >= b {
        a
    }else{
        b
    }
}
```
Here we tell compiler that `a`, `b` and the return value must live same amount of time.

### lifetime elision
While whenever you use refereces in functions you need to annotate for lifetimes, Rust compiler somethimes can infer lifetime of refereces automatically, so we can omit lifetime labels, this is called lifetime elision.

Rust lifetime elision rules are:

- no output referece

  When we don't have any output reference compiler sets automatically different lifetimes to inputs. so
  ```rust
  fn test(x: &'a i32, y: &'b i32)->i32
  ```
  can be written as
  ```rust
  fn test(x: &i32, y: &i32)->i32
  ```

- one in, one out

  When function has only one input referece and one output referece rust assumes output referece and input lifetimes are same. so output memory is valid as much as passed parameter lives, so
  ```rust
  fn test(x: &'a i32)->&'a i32
  ```
  can be written as
  ```rust
  fn test(x: &i32)->&i32
  ```


- when we have reference to `self`

  Rust sets lifetime of output referece same as `self` so output will live as much as main object lives. this is the default behavior so if we need different lifetime for output we need still manual labeling. so
  ```rust
  fn method(&'a self, y: &'b i32, z: &'c i32) -> &'a i32
  ```
  can be written as
  ```rust
  fn method(&self, y: &i32, z: &i32) -> &i32
  ```

### Lifetime bounds

lifetime binding means we tell compiler that a generic type must outlive a minimum amount of time. it is written as `T: 'a` or `T: 'static` or `'a : 'b`. the two first ones are read as **T outlives lifetime 'b** or **T outlives lifetime 'static** which means type `T` must live at least as much as `'a` lives or `'static` and the third is read as **lifetime 'a outlives lifetime 'b** which means we are sure that `'a` is valid while `'b` is valid.

When we are using generics in rust (`fn f<T>(...)` or `struct t<T> {...}` or `trait i<T>{...}`) we can face usage of refereces with the generic type `T`.
- The code can use a referece if `T` anywhere in it
- `T` be a type which has a reference member in it (e.g. `struct` with a referece member)
- `T` can be a reference type itself (e.g. `T` be `&Data`)

So as generic types may deal with refereces in many ways we somethimes need to bind some lifetime to be sure about their refereces lifetimes.
When we say `T: 'a` it means all references in `T` must outlive `'a` while when we say `&'a T` it means the referece to `T` must outlive `'a`.

So by `T: 'a` we can be sure references in `T` will live enough. so we can say:
```rust
struct Data<'a>{
  value: &'a i32
}
```
Here we defined a lifetime label `'a` in `Data<'a>` part and used it to tell compiler that `value` member must outlive `'a` in `&'a i32` part.

And we can say:
```rust
struct Data<'a, T>{
  value: &'a i32;
  other: T
}
```
Here we defined a generic type `T` and a lifetime `'a` and told the compiler we have a referece to a `i32` value that must outlive `'a` and some `other` member with type `T` (what happens if `T` be a reference type or a struct with some reference members?)

```rust
struct Data<'a, T: 'b>{
  value: &'a i32;
  other: T
}
```
Here we told compiler all reference memebers of `T` must outlive `'b` which is different than `'a`
```rust
struct Data<'a, T: 'b, 'b: 'a>{
  value: &'a i32;
  other: T
}
```
Here we say samething as previous one but we also set a constrain on `'b` that it must outlive `'a`



### `'static` lifetime

`'static` roughly means unlimited lifetime, but there are some misunderstandings about it. my main motivation of this post is to talk about `'static` lifetime. so lets first see what is it and why it is called static.

Imagine we have a function that gets no input and returns a reference to something; or it gets some input but it doesn't return of them, instead it returns a referece which is not related to inputs by reference:
```rust
fn test()->&i32
// or
fn test()->&Data
```

Here we have serious problem. who owns the returning value? we are returning a referece to a value that can be owned by function which is not valid as after function call owned value will be freed so we end up with a dangling pointer; or we can return a referece to a global variable which is allocated **statically** which means it is never freed. static allocation means that variable is never freed and it is valid for the entire life of program. in rust global variables must be defined with `static` keyword instead of `let` which causes variable allocate in data segment of program with a fixed address and infinite lifetime. `static` variables are not allocated or deallocated, they are just loaded into ram on start of program and unloaded and program exit, so it is valid for entire program lifetime. such a variable has a special lifetime which is called `'static`.

So returning a value with `'static` lifetime causes no problem:
```rust
static SOMETHING: Data = Data { _value: 10 };

#[derive(Debug)]
struct Data{
  _value: i32
}

fn test() -> &'static Data {
    &SOMETHING
}

fn main() {
    let z = test();
    println!("{:?}", z);
}
```
When we set `'static` lifetime label on variable we are telling compiler to only accept a variable that can outlives more than all other variables in program! so here in `test` function we can only return such a variable (which can be a `static` variable that lives in data segment or a variable that lives in heap and never dropped (`Box::leak`):
```rust
#[derive(Debug)]
struct Data{
  _value: i32
}

fn test() -> &'static Data {
  let boxed = Box::new(Data { _value: 10 });
  Box::leak(boxed)
}

fn main() {
    let z = test();
    println!("{:?}", z);
}
```
Here return value of `test` is a pointer to heap memory which is not droped so it satisfies `'static` lifetime.

So we can only return a reference with `'static` lifetime from functions when the function is not returning one of its parameters. It can be a 1) `static` (global) variable which is allocated on data segment or 2) a `'static` referece to a leaked heap allocated memory (this costs memory leak of-course). the only important thing is the memory must not be dropped or moved anytime after creation of referece.


```rust
#[derive(Debug)]
struct Data{
  _value: i32
}

fn test() -> &'static Data {
    &Data{_value: 10}
}

fn main() {
    let z = test();
    println!("{:?}", z);
}
```
Here `Data{_value: 10}` is a temporary value which by default has smallest possible lifetime but it can be extended by some rules, here [constant promotion](https://doc.rust-lang.org/reference/destructors.html?highlight=prom#constant-promotion) is applied so compiler promotes the it to `static` as its value can be evaluated at compile time so it can be stored in data segment. we are returning a referece to it so result type is `&'static Data`.

In bounded lifetimes like `T: 'static` we say type `T` is bounded by a `'static` lifetime which means it can life for any desired time (entire program or less). `T: 'static` includes all `&'static T` and owned types! this means `T` can be a referece (borrowed) with `'static` lifetime or an owned type. owned data is guaranteed to be always valid for its owner, so while owner exists data exists too (even to the end of program). this means we can have `'static` bounded types which are created, manipulated and dropped on runtime while they are owned. types like `String` or `Vec` are owned types so they are acceptable as a `T: 'static`!

