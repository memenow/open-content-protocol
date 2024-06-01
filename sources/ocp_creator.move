module 0x0::ocp_creator {
    use sui::tx_context;
    use sui::object;
    use sui::transfer;
    use std::string::String;

    /// The `Creator` struct represents a creator in the OCP.
    /// It contains information about the creator, such as their name, URL, description, and avatar.
    public struct Creator has key, store {
        id: UID,
        name: address,
        url: String,
        description: String,
        avatar: String,
        member_prices: vector<u64>,
    }

    /// Mints a new creator and transfers it to the sender.
    /// 
    /// # Arguments
    /// 
    /// * `url` - The URL of the creator.
    /// * `description` - The description of the creator.
    /// * `avatar` - The avatar of the creator.
    /// * `ctx` - The transaction context.
    public entry fun mint_creator(
        url: String,
        description: String,
        avatar: String,
        member_prices: vector<u64>,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        let nft = Creator {
            id: object::new(ctx),
            name: sender,
            url,
            description,
            avatar,
            member_prices,
        };
        transfer::transfer(nft, sender);
    }
      
    /// Updates the URL, description, and avatar of an existing creator.
    /// 
    /// # Arguments
    /// 
    /// * `creator` - A mutable reference to the `Creator` object to be updated.
    /// * `url` - The new URL of the creator.
    /// * `description` - The new description of the creator.
    /// * `avatar` - The new avatar of the creator.
    /// * `_` - The transaction context (unused).    
    public entry fun update_creator(
        creator: &mut Creator,
        url: String,
        description: String,
        avatar: String,
        _: &TxContext
    ) {
        creator.url = url;
        creator.description = description;
        creator.avatar = avatar;
    }

    public fun get_creator_name(creator: &Creator): address {
        creator.name
    }

    public fun get_member_prices(creator: &Creator): &vector<u64> {
        &creator.member_prices
    }

}