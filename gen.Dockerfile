FROM rust:1.31
WORKDIR /usr/src/ff-cl-gen
RUN USER=root cargo init --bin
COPY ./rust-toolchain ./rust-toolchain
RUN cargo build --release
COPY ./Cargo.toml ./Cargo.toml
RUN cargo fetch
COPY ./src ./src
RUN cargo build --release

RUN echo '\
echo "\
extern crate rand_core; \n#\
[macro_use] \n\
extern crate fff; \n\
use fff::{Field, PrimeField, PrimeFieldDecodingError, PrimeFieldRepr};  \n#\
[derive(PrimeField)]  \n#\
[PrimeFieldModulus = \"$2\"]  \n#\
[PrimeFieldGenerator = \"7\"]  \n\
struct Fp(FpRepr);  \n\
fn main() {  \n\
    println!(\"{}\", ff_cl_gen::field::<Fp>(\"$1\")); \n\
}" > ./src/main.rs \n\
rm -rf ./target/release/ff-cl-gen > /dev/null  2>&1 \n\
cargo build --release > /dev/null  2>&1 \n\
./target/release/ff-cl-gen' > ./gen.sh

ENTRYPOINT ["sh", "./gen.sh"]
