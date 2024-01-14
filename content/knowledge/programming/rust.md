---
title: rust
summary: Notes on Rust (blazingly fast!)
---

## Tooling

Install Rust with the official [installation script](https://sh.rustup.rs).

- `rustc`: The Rust compiler
- `rustup`: Manages Rust versions/updates
- `cargo`: Rust's build tool

## Running and building

Cargo is the primary tool development with Rust.

### New project

```sh
cargo new --bin NAME # create a application
cargo new --bin NAME # create a library
```

Directory structure:

```
.
├── Cargo.toml
└── src
    └── main.rs
```

`Cargo.toml` contains project meta info and dependencies.

### Run project

```sh
cargo run
```

"pure" rust:

```sh
rustc src/main.rs && ./main # for linux
```

### Build project

```sh
cargo build # fast compilation
cargo build --release # slower compilation with optimizations
```

```
.
├── Cargo.lock
├── Cargo.toml
├── main
├── src
│   └── main.rs
└── target
    ├── debug
    │   ├── fibonacci
    └── release
        ├── fibonacci
```

`Cargo.lock` allows reproducible builds. `target/release` contains the release build, `target/debug` the default build. (fibonacci is the projects's name and the executable's name)

Also available: `cargo test`, `cargo doc` and `cargo publish`.

## Types

### Scalars

```rust
let number1: u8 = 1;
let number2: u16 = 10;
let number3: u32 = 100;
let number4: u64 = 1_000;
let number5: usize = 10_000;

let number6: i8 = -1;
let number7: i16 = -10;
let number8: i32 = -100; // default
let number9: i64 = -1_000;
let number0: isize = -10_000;

let decimal1: f32 = 3.14;
let decimal2: f64 = 2.78; // default

let b1: bool = true;
let b2: bool = false;

let char1: char = 'z';
let char2: char = '';
```

### Compounds

```rust
let t1: (u8, u8, bool) = (1, 10, true);
let (x, y, z) = t1;

let arr = [1, 2, 3, 4, 5]; // FIXED size
```

### Mutability

Rust's default for variables is immutability. Therefore, once assigned the value of a variable cannot be altered. The `mut` keyword allows to define mutable variables:

```rust
let mut var = String::new()
```

## Functions

```rust
fn main() {
    // main entryp point
}
```

## Controls

### IF-Else

```rust
if number < 5 {
    println!("True");
} else {
    println!("False")
}
```

### Loops

1. loop

```rust
loop {
    println!("Loop forever till break!");
    if condition {
        break;
    }
}
```

2. while

```rust
let mut i = 0;
while i < 10 {
    println!("{}", i);
    i = i + 1;
}
```

3. for

```rust
let mut sum = 0;
for n in 1..11 { // including start and excluding end
    sum += n;
}
println!("{}", sum);
```

```rust
let v = &["rust", "go", "c++"];
for text in v {
    println!("I like {}.", text);
}
```
