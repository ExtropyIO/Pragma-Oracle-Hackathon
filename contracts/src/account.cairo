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
    use starknet::get_caller_address;
    use starknet::get_contract_address;
    use starknet::info::get_block_timestamp;

    ////////////////////////////////
    // External Imports
    ////////////////////////////////


    const ESCAPE_TYPE_GUARDIAN : u8 = 1;
    const ESCAPE_TYPE_SIGNER : u8 = 2;
    const ESCAPE_SECURITY_PERIOD: u64 = 180;  // 3 minutes for demonstration

    ////////////////////////////////    
    // Storage
    ////////////////////////////////
    struct Storage {
        signer: felt252,
        guardian: felt252,
        guardian_backup: felt252,
        escape_time: u64,
        escape_type: u8,
    }

    ////////////////////////////////
    // Events
    ////////////////////////////////

    #[event]
    fn SignerChanged(new_signer: felt252) {}

    #[event]
    fn GuardianChanged(new_guardian: felt252) {}

    #[event]
    fn GuardianBackupChanged(new_guardian: felt252) {}

    #[event]
    fn EscapeGuardianTriggered(activated_at: u64) {} 

    #[event]
    fn GuardianEscaped(new_guardian: felt252) {}

    #[event]
    fn EscapeSignerTriggered(activated_at: u64) {}

    #[event]
    fn SignerEscaped(new_guardian: felt252) {}

    #[event]
    fn EscapeCanceled() {}

    ////////////////////////////////
    // Constructor
    ////////////////////////////////
    #[constructor]
    fn constructor(_signer: felt252, _guardian: felt252, _guardian_backup: felt252) {
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
        // Validate caller.
        assert(starknet::get_caller_address().is_zero(), 'INVALID_CALLER');

        // Check the tx version here, since version 0 transaction skip the __validate__ function.
        let tx_info = starknet::get_tx_info().unbox();
        assert(tx_info.version != 0, 'INVALID_TX_VERSION');

        // TODO(ilya): Implement multi call.
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
    fn get_escape_type() ->  u8 {
        escape_type::read()
    }

    #[view]
    fn get_escape_time() -> u64 {
        escape_time::read()
    }

    ////////////////////////////////
    // External Functions
    ////////////////////////////////
    #[external]
    fn change_signer(new_signer: felt252) {

        // call via execute
        assert_only_self();

        // check for null/zero
        assert(new_signer != 0, 'SIGNER INVALID');

        // update signer
        signer::write(new_signer);

        // emit
        SignerChanged(new_signer);

    }

    #[external]
    fn change_guardian(new_guardian: felt252) {

        // call via execute
        assert_only_self();
 
        // check if there is a guardin backup 
        if (new_guardian == 0) {
            assert(guardian_backup::read() == 0, 'NEW GUARDIAN INVALID');
        }
       
        // check if there 
        guardian::write(new_guardian);

        // emit
        GuardianChanged(new_guardian);

    }

    #[external]
    fn change_guardian_backup(new_guardian_backup: felt252) {

        // call via execute
        assert_only_self();

        // check if have a guardian initially
        assert(guardian::read() != 0, 'GUARDIAN REQUIRED');

        // update guardian backup
        guardian_backup::write(new_guardian_backup);

        // emit
        GuardianBackupChanged(new_guardian_backup);

    }

    #[external]
    fn trigger_escape_signer() {
        // call via execute
        assert_only_self();

        // no escape when there is no guardian 
        assert(guardian::read() != 0, 'GUARDIAN REQUIRED');

        // no escape if there is an guardian escape triggered by the signer in progress
        assert(escape_type::read() == ESCAPE_TYPE_SIGNER, 'CANNOT OVERRIDE ESCAPE');

        // get block timestamp
        let blocktime = get_block_timestamp(); // u64

        // update escape with signer
        escape_time::write(blocktime + ESCAPE_SECURITY_PERIOD);
        escape_type::write(ESCAPE_TYPE_SIGNER);

        EscapeSignerTriggered(blocktime + ESCAPE_SECURITY_PERIOD);


    }

    #[external]
    fn trigger_escape_guardian() {
        // call via execute
        assert_only_self();

        // no escape when there is no guardian 
        assert(guardian::read() != 0, 'GUARDIAN REQUIRED');

        // get block timestamp
        let blocktime = get_block_timestamp(); // u64

        // update escape with guardian
        escape_time::write(blocktime + ESCAPE_SECURITY_PERIOD);
        escape_type::write(ESCAPE_TYPE_GUARDIAN);

        // emit
        EscapeGuardianTriggered(blocktime + ESCAPE_SECURITY_PERIOD);
    }

    #[external]
    fn cancel_escape() {
        // call via execute
        assert_only_self();

        // no escape when there is no guardian 
        assert(guardian::read() != 0, 'GUARDIAN REQUIRED');

        assert(escape_type::read() != 0, 'NO ACTIVE ESCAPE');

        // reset escape
        escape_time::write(0);
        escape_type::write(0);

        // emit 
        EscapeCanceled();

    }


    // called after the X amount of time
    #[external]
    fn escape_guardian(new_guardian: felt252){
        // call via execute
        assert_only_self();

        // no escape when there is no guardian 
        assert(guardian::read() != 0, 'GUARDIAN REQUIRED');

        // get block timestamp
        let blocktime = get_block_timestamp(); // u64

        // check if escape active
        assert(escape_time::read() != 0, 'NOT ESCAPING');

        // check timer 
        assert(escape_time::read() <= blocktime, 'ESCAPE NOT ACTIVE');

        // check escape type
        assert(escape_type::read() == ESCAPE_TYPE_GUARDIAN, 'ESCAPE TYPE INVALID');

        // reset escape
        escape_time::write(0);
        escape_type::write(0);

        // check if not zero
        assert(new_guardian != 0, 'INVALID NEW GUARDIAN');

        // update guardin
        guardian::write(new_guardian);

        // emit
        GuardianEscaped(new_guardian);
    }

    #[external]
    fn escape_singer(new_signer: felt252){
        // call via execute
        assert_only_self();

        // no escape when there is no guardian 
        assert(guardian::read() != 0, 'GUARDIAN REQUIRED');

        // get block timestamp
        let blocktime = get_block_timestamp(); // u64

        // check if escape active
        assert(escape_time::read() != 0, 'NOT ESCAPING');

        // check timer 
        assert(escape_time::read() <= blocktime, 'ESCAPE NOT ACTIVE');

        // check escape type
        assert(escape_type::read() == ESCAPE_TYPE_SIGNER, 'ESCAPE TYPE INVALID');

         // reset escape
        escape_time::write(0);
        escape_type::write(0);

        // check if not zero
        assert(new_signer != 0, 'INVALID NEW SIGNER');

        // update guardin
        signer::write(new_signer);

        // emit
        SignerEscaped(new_signer);
    }
    
    ////////////////////////////////
    // Internal functions
    ////////////////////////////////
    fn assert_only_self() {
        let self = get_contract_address();
        let caller_address = get_caller_address();
        assert(self == caller_address, 'ONLY SELF')
    }
}
