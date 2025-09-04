module spike_fun::asset_manager {
    use std::option;
    use std::string::{String};
    use std::bcs;
    use supra_framework::fungible_asset::{
        Self,
        MintRef,
        TransferRef,
        BurnRef,
        Metadata,
        FungibleAsset
    };
    use supra_framework::object::{Self, Object, ExtendRef};
    use supra_framework::primary_fungible_store;
    friend spike_fun::spike_fun;

    struct LST has key {
        fa_generator_extend_ref: ExtendRef,
        token_creation_nonce: u64
    }

    #[resource_group_member(group = supra_framework::object::ObjectGroup)]
    struct ManagedFungibleAsset has key {
        mint_ref: MintRef,
        transfer_ref: TransferRef,
        burn_ref: BurnRef
    }

    fun init_module(sender: &signer) {
        let constructor_ref = object::create_named_object(sender, b"FA Generator");
        let fa_generator_extend_ref = object::generate_extend_ref(&constructor_ref);
        let lst = LST { fa_generator_extend_ref: fa_generator_extend_ref,
                        token_creation_nonce: 0
        };
        move_to(sender, lst);
    }

    public(friend) fun create_fa(
        name: String,
        symbol: String,
        decimals: u8,
        icon_uri: String,
        project_uri: String
    ) : address acquires LST {
        let lst = borrow_global_mut<LST>(@spike_fun);
        let current_nonce = lst.token_creation_nonce;
        lst.token_creation_nonce = current_nonce + 1;
        let fa_key_seed = bcs::to_bytes(&current_nonce);
        let fa_generator_signer =
            object::generate_signer_for_extending(&lst.fa_generator_extend_ref);
        let fa_obj_constructor_ref =
            &object::create_named_object(&fa_generator_signer, fa_key_seed);
        let fa_obj_signer = object::generate_signer(fa_obj_constructor_ref);
        primary_fungible_store::create_primary_store_enabled_fungible_asset(
            fa_obj_constructor_ref,
            option::none(),
            name,
            symbol,
            decimals,
            icon_uri,
            project_uri
        );
        let mint_ref = fungible_asset::generate_mint_ref(fa_obj_constructor_ref);
        let burn_ref = fungible_asset::generate_burn_ref(fa_obj_constructor_ref);
        let transfer_ref = fungible_asset::generate_transfer_ref(fa_obj_constructor_ref);
        move_to(
            &fa_obj_signer,
            ManagedFungibleAsset { mint_ref, transfer_ref, burn_ref }
        );
        object::address_from_constructor_ref(fa_obj_constructor_ref)
    }

    public(friend) fun mint(
        token_address: address,
        to: address,
        amount: u64,
    ) acquires ManagedFungibleAsset {
        let asset: Object<Metadata> = object::address_to_object(token_address);
        let managed_fungble_asset = authorized_borrow_refs(asset);
        let to_wallet = primary_fungible_store::ensure_primary_store_exists(to, asset);       
        
        let fa = fungible_asset::mint(&managed_fungble_asset.mint_ref, amount);
        fungible_asset::deposit_with_ref(
            &managed_fungble_asset.transfer_ref, to_wallet, fa
        );
    }

    public(friend) fun transfer(
        token_address: address,
        from: address,
        to: address,
        amount: u64
    ) acquires ManagedFungibleAsset {
        let asset: Object<Metadata> = object::address_to_object(token_address);
        let transfer_ref = &authorized_borrow_refs(asset).transfer_ref;
        let from_wallet = primary_fungible_store::primary_store(from, asset);
        let to_wallet = primary_fungible_store::ensure_primary_store_exists(to, asset);
        let fa = withdraw(from_wallet, amount, transfer_ref);
        deposit(to_wallet, fa, transfer_ref);
    }

    public(friend) fun burn(
        token_address: address,
        from: address,
        amount: u64,
    ) acquires ManagedFungibleAsset {
        let asset: Object<Metadata> = object::address_to_object(token_address);
        let burn_ref = &authorized_borrow_refs(asset).burn_ref;
        let from_wallet = primary_fungible_store::primary_store(from, asset);
        fungible_asset::burn_from(burn_ref, from_wallet, amount);
    }

    #[view]
    public fun get_balance(
        token_address: address,
        owner_addr: address
    ): u64 {
        let fa_metadata_obj: Object<Metadata> = object::address_to_object(token_address);
        primary_fungible_store::balance(owner_addr, fa_metadata_obj)
    }

    #[view]
    public fun get_total_supply(token_address: address): u128 {
        let asset: Object<Metadata> = object::address_to_object(token_address);
        let total_supply = fungible_asset::supply(asset);
        if (option::is_some(&total_supply)) {
            *option::borrow(&total_supply)
        } else { 0u128 }
    }
    
    public(friend) fun deposit<T: key>(
        store: Object<T>, fa: FungibleAsset, transfer_ref: &TransferRef
    ) {
        fungible_asset::deposit_with_ref(transfer_ref, store, fa);
    }

    public(friend) fun withdraw<T: key>(
        store: Object<T>, amount: u64, transfer_ref: &TransferRef
    ): FungibleAsset {
        fungible_asset::withdraw_with_ref(transfer_ref, store, amount)
    }

    inline fun authorized_borrow_refs(
        asset: Object<Metadata>
    ): &ManagedFungibleAsset acquires ManagedFungibleAsset {
        borrow_global<ManagedFungibleAsset>(object::object_address(&asset))
    }

    public fun is_account_registered(
        token_address: address,
        account: address,
    ): bool {
        let asset: Object<Metadata> = object::address_to_object(token_address);
        primary_fungible_store::primary_store_exists(account, asset)
    }

    public fun register(
        token_address: address,
        account: &signer
    ) {
        let asset: Object<Metadata> = object::address_to_object(token_address);
        primary_fungible_store::ensure_primary_store_exists(std::signer::address_of(account), asset);
    }
}
