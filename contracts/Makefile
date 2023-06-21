build: FORCE
	scarb build

clean: FORCE
	scarb clean

fmt: FORCE
	scarb fmt

test: FORCE
	cargo run --bin cairo-test -- --starknet --path $(dir)

starknet-declare:
	starknet declare --contract ${file} --account version_2 --show_trace

starknet-deploy:
	starknet deploy --class_hash ${hash} --account version_2 
FORCE: