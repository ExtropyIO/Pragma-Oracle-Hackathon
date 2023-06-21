use serde::Serde;
use starknet::ContractAddress;
use array::ArrayTrait;
use array::SpanTrait;
use option::OptionTrait;


#[derive(Drop, Serde)]
struct Call {
    to: ContractAddress,
    selector: felt252,
    calldata: Array<felt252>
}

#[account_contract]
mod Account {

    ////////////////////////////////
    // Internal Imports
    ////////////////////////////////
    use array::ArrayTrait;
    use array::SpanTrait;
    use box::BoxTrait;
    use ecdsa::check_ecdsa_signature;
    use option::OptionTrait;
    use super::Call;
    use starknet::ContractAddress;
    use zeroable::Zeroable;
    use serde::ArraySerde;

    ////////////////////////////////
    // External Imports
    ////////////////////////////////

    ////////////////////////////////
    // Storage
    ////////////////////////////////
    struct Storage {
        signer: felt252,
        guardian: felt252,
        guardian_backup: felt252,
    }

    ////////////////////////////////
    // Events
    ////////////////////////////////
    #[event]
    fn EscapeGuardian() {}

    #[event]
    fn EscapeSigner() {}

    #[event]
    fn CancelEscape() {}

    ////////////////////////////////
    // Constructor
    ////////////////////////////////
    #[constructor]
    fn constructor(_signer: felt252, _guardian: felt252, _guardian_backup: felt252) {
        // need some checks
        signer::write(_signer);
        guardian::write(_guardian);
        guardian_backup::write(_guardian_backup);
    }

    ////////////////////////////////
    // Account Interface
    ////////////////////////////////
    fn validate_transaction() -> felt252 {
        let tx_info = starknet::get_tx_info().unbox();
        let signature = tx_info.signature;
        assert(signature.len() == 2_u32, 'INVALID_SIGNATURE_LENGTH');
        assert(
            check_ecdsa_signature(
                message_hash: tx_info.transaction_hash,
                public_key: signer::read(),
                signature_r: *signature[0_u32],
                signature_s: *signature[1_u32],
            ),
            'INVALID_SIGNATURE',
        );

        starknet::VALIDATED
    }

    #[external]
    fn __validate_deploy__(
        class_hash: felt252, contract_address_salt: felt252, signer_: felt252
    ) -> felt252 {
        validate_transaction()
    }

    #[external]
    fn __validate_declare__(class_hash: felt252) -> felt252 {
        validate_transaction()
    }

    #[external]
    fn __validate__(
        contract_address: ContractAddress, entry_point_selector: felt252, calldata: Array<felt252>
    ) -> felt252 {
        validate_transaction()
    }

    #[external]
    #[raw_output]
    fn __execute__(mut calls: Array<Call>) -> Span<felt252> {
        assert(starknet::get_caller_address().is_zero(), 'INVALID_CALLER');

        let tx_info = starknet::get_tx_info().unbox();
        assert(tx_info.version != 0, 'INVALID_TX_VERSION');

        assert(calls.len() == 1_u32, 'MULTI_CALL_NOT_SUPPORTED');
        let Call{to, selector, calldata } = calls.pop_front().unwrap();

        starknet::call_contract_syscall(
            address: to, entry_point_selector: selector, calldata: calldata.span()
        )
            .unwrap_syscall()
    }


    ////////////////////////////////
    // View Functions
    ////////////////////////////////
    #[view]
    fn get_signer() -> felt252 {
        signer::read()
    }

    #[view]
    fn get_guardian() -> felt252 {
        guardian::read()
    }

    #[view]
    fn get_guardian_backup() -> felt252 {
        guardian_backup::read()
    }

    #[view]
    fn get_escape()  {
    }

    ////////////////////////////////
    // External Functions
    ////////////////////////////////
    #[external]
    fn change_signer(new_signer: ContractAddress) {

    }

    #[external]
    fn change_guardian(new_guardian: ContractAddress) {

    }

    #[external]
    fn change_guardian_backup(new_guardian_backup: ContractAddress) {

    }

    #[external]
    fn escape_signer() {

    }

    #[external]
    fn escape_guardian() {

    }

    #[external]
    fn cancel_escape() {

    }
    

    ////////////////////////////////
    // Internal functions
    ////////////////////////////////
}
