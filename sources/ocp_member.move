module 0x0::ocp_member {
    use sui::tx_context;
    use sui::object;
    use sui::transfer;
    use std::string::String;

    /// The `Member` struct represents a member in the OCP.
    /// It contains information about the member, such as their name, URL, description, avatar, and creator.
    public struct Member has key, store{
        id: UID,
        name: address,
        url: String,
        description: String,
        avatar: String,
        creator: address,
    }

    /// The `Paid` struct represents a paid membership in the OCP.
    /// It contains information about the paid membership, such as the member's address, creator ID, URL, and description.
    public struct Paid has key, store{
        id: UID,
        member: address,
        creator: ID,
        url: String,
        description: String,
    }

    /// Mints a new member and transfers it to the sender.
    /// 
    /// # Arguments
    /// 
    /// * `creator` - The address of the creator associated with the member.
    /// * `url` - The URL of the member.
    /// * `description` - The description of the member.
    /// * `avatar` - The avatar of the member.
    /// * `ctx` - The transaction context.
    public entry fun mint_member(
        creator: address,
        url: String,
        description: String,
        avatar: String,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);        
        let nft = Member {
            id: object::new(ctx),
            name: sender,
            url,
            description,
            avatar,
            creator,
        };
        transfer::transfer(nft, sender);
    }

    /// Mints a new paid membership and transfers it to the sender.
    /// 
    /// # Arguments
    /// 
    /// * `creator` - A reference to the `Creator` object associated with the paid membership.
    /// * `url` - The URL of the paid membership.
    /// * `description` - The description of the paid membership.
    /// * `ctx` - The transaction context.
    public entry fun mint_paid(
        creator: &0x0::ocp_creator::Creator,
        url: String,
        description: String,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);        
        let nft = Paid {
            id: object::new(ctx),
            member: sender,
            creator: object::id(creator),
            url,
            description,
        };
        transfer::transfer(nft, sender);
    }

}