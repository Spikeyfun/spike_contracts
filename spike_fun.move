module spike_fun::spike_fun {
    use std::string::{String};

    struct ProtocolFees has drop {
        swap_platform_fee_bps: u64,
        swap_creator_fee_bps: u64,
        deploy_fee: u64,
        migrator_reward_bps: u64,
        migration_gas_fee: u64,        
        platform_fee_address: address,
        benefitiary_address_for_excess: address,
        min_trade_supra_amount: u64,
        migration_slippage_bps: u64,
    }

    struct LaunchParameters has drop {
        raise_limit_min: u64,
        raise_limit_max: u64,
        virtual_mult_range_meme: u64,
        virtual_mult_range_DAO: u64,
        virtual_mult_range_BIG_DAO: u64,
        tokens_per_sup: u64,
        raising_percentage_meme_bps: u64,
        raising_percentage_DAO_bps: u64,
        raising_percentage_BIG_DAO_bps: u64,
        unstake_period_seconds_default: u64,
        unstake_period_seconds_min: u64,
        unstake_period_seconds_max: u64,
        default_token_decimals: u8,
        staking_rate: u64,
    }

    struct PoolStateView has drop {
        virtual_token_reserves: u128,
        virtual_supra_reserves: u128,
        is_completed: bool,
        is_migrated_to_dex: bool,
        target_supra_dex_threshold: u64,
        dev_address: address,
    }


    native public entry fun deploy(
        caller: &signer,
        raising: u64,
        description: String,
        name: String,
        symbol: String,
        uri: String,
        website: String,
        telegram: String,
        twitter: String,
        github: String,
        stream: String,
        unstake_period_seconds: u64
    );

    native public entry fun swap_supra_for_exact_tokens(
        caller: &signer,
        token_address: address,
        buy_token_amount: u64,
        max_supra_in: u64
    );

    native public entry fun buy_tokens_for_exact_supra(
        caller: &signer,
        token_address: address,
        supra_in_amount: u64,
        min_token_out: u64
    );

    native public entry fun deploy_and_buy_for_exact_supra(
        caller: &signer,
        raising: u64,
        description: String,
        name: String,
        symbol: String,
        uri: String,
        website: String,
        telegram: String,
        twitter: String,
        github: String,
        stream: String,
        unstake_period_seconds: u64,
        supra_in_amount: u64, 
        min_token_out: u64
    );

    native public entry fun swap_exact_tokens_for_supra(
        caller: &signer,
        token_address: address,
        sell_token_amount: u64,
        min_supra_out: u64
    );

    native public entry fun stake(
        user: &signer,
        token_address: address,
        stake_amount: u64
    );

    native public entry fun unstake(
        user: &signer,
        token_address: address,
        unstake_amount: u64
    );

    native public entry fun harvest(
        user: &signer,
        token_address: address
    );

    native public entry fun queue_update_all_configs(
        admin: &signer,
        new_creator_fee_bps: u64,
        new_platform_fee: u64,
        new_deploy_fee: u64,
        new_platform_fee_address: address,
        new_benefitiary_address_for_excess: address,
        new_raise_limit_min: u64,
        new_raise_limit_max: u64,
        new_virtual_mult_range_meme: u64,
        new_virtual_mult_range_DAO: u64,
        new_virtual_mult_range_BIG_DAO: u64,
        new_tokens_per_sup: u64,
        new_raising_percentage_meme: u64,
        new_raising_percentage_DAO: u64,
        new_raising_percentage_BIG_DAO: u64,
        new_staking_rate: u64,
        new_unstake_period_seconds_min: u64,
        new_unstake_period_seconds_max: u64,
        new_unstake_period_seconds_default: u64,
        new_migrator_reward_bps: u64,
        new_migration_gas_amount: u64,
        new_token_decimals: u8,
        new_min_trade_supra_amount: u64,
        new_deadline: u64,
        new_supply_deviation_tolerance_bps: u64,

    );

    native public entry fun execute_queued_config(executor: &signer);
        
    native public entry fun cancel_queued_config(admin: &signer);

    native public entry fun execute_manual_migration(
        caller: &signer,
        token_address: address,
    );

    native public fun execute_manual_migration_internal(
        caller: &signer,
        token_address: address,
    );

    #[view]
    native public fun buy_token_amount(
        token_address: address, buy_token_amount: u64
    ): u128;

    #[view]
    native public fun get_current_pool_supra_balance(
        token_address: address
    ): u64;

    #[view]
    native public fun buy_supra_amount(
        token_address: address, buy_supra_amount: u64
    ): u128;

    #[view]
    native public fun sell_token(
        token_address: address, sell_token_amount: u64
    ): u128;

    #[view]
    native public fun get_current_price(
        token_address: address,
    ): u128;

    #[view]
    native public fun get_pool_state(
        token_address: address
    ): PoolStateView;

    #[view]
    native public fun buy_price_with_fee(
        token_address: address, buy_meme_amount: u64
    ): u128;

    #[view]
    native public fun sell_price_with_fee(
        token_address: address, sell_meme_amount: u64
    ): u128;

    #[view]
    native public fun get_price_impact(
        token_address: address,
        amount: u64,
        is_buy: bool
    ): u64;

    #[view]
    native public fun get_bonding_curve_progress_data(
        token_address: address
    ): (u64, u64, bool);

    #[view]
    native public fun calculate_virtual_pools(raising: u64): (u128, u128);

    #[view]
    native public fun get_percentage_bps_reward(raising: u64): u64;

    #[view]
    native public fun get_resource_address(): address;

    #[view]
    native public fun get_platform_fees(): (u64, u64, address);

    #[view]
    native public fun get_launch_parameters(): LaunchParameters;

    #[view]
    native public fun get_protocol_fees(): ProtocolFees;

    #[view]
    native public fun get_user_stake_info(
        token_address: address,
        user_addr: address
    ): (u64, u64);

    #[view]
    native public fun get_hodl_pool_stats(
        token_address: address
    ) : (u64, u128);

    #[view]
    native public fun get_raise_limits_config(): (u64, u64);

    #[view]
    native public fun calculate_ideal_projected_supply_base(
        initial_v_token: u128,
        initial_v_supra: u128,
        fundraising_goal_supra: u64
    ): u128;
}
