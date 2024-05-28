module 0x0::ocp_creator {
    use sui::tx_context;
    use sui::object;
    use sui::transfer;
    use std::string::String;

    public struct Creator has key, store {
        id: UID,
        name: address,
        url: String,
        description: String,
        avatar: String,
    }

    public entry fun mint_creator(
        url: String,
        description: String,
        avatar: String,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        let nft = Creator {
            id: object::new(ctx),
            name: sender,
            url,
            description,
            avatar,
        };
        transfer::transfer(nft, sender);
    }
    
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

}